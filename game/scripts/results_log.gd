## Writes one session to user://ear_test_results/<tester>_<mode>_<timestamp>.csv.
## An existing file is never overwritten: a clash gets _2, _3, ... before ".csv".
## Every row is flushed as soon as it is written, so a crash keeps every row written so far.
## ear_test.gd writes a scored row the moment the tester answers, but a practice row only when
## its 2 s of feedback end (so a pause during the feedback counts in that row): a crash or a
## forced kill during that feedback can lose that one unscored practice row.
## A write failure never stops the session: it is recorded in `error_message`, the session
## shows a red banner at once, and the results screen shows it with the attempted path.
extends RefCounted

const TrialPlan := preload("res://scripts/trial_plan.gd")

const DEFAULT_DIR: String = "user://ear_test_results"
## Spaces trimmed from the ends of a tester ID besides ASCII whitespace (which strip_edges()
## handles): no-break, Ogham, en/em/thin/hair, zero-width, narrow no-break, medium
## mathematical and ideographic spaces, and the byte-order mark.
const EXTRA_EDGE_SPACES: Array[int] = [0x00A0, 0x1680, 0x2000, 0x2001, 0x2002, 0x2003, 0x2004,
		0x2005, 0x2006, 0x2007, 0x2008, 0x2009, 0x200A, 0x200B, 0x202F, 0x205F, 0x3000, 0xFEFF]
## Unicode identifier characters (XID_Continue) that are neither letters, digits nor
## combining marks: connector punctuation other than '_' (‿ ⁀ ⁔ ︳ ︴ ﹍ ﹎ ﹏ ＿) and the
## Other_ID_Continue dots, numerals and joiners (· · ፩-፱ ᧚ ZWNJ ZWJ ・ ･).
const NON_LETTER_ID_CHARS: Array[int] = [0x00B7, 0x0387, 0x1369, 0x136A, 0x136B, 0x136C, 0x136D,
		0x136E, 0x136F, 0x1370, 0x1371, 0x19DA, 0x200C, 0x200D, 0x203F, 0x2040, 0x2054, 0x30FB,
		0xFE33, 0xFE34, 0xFE4D, 0xFE4E, 0xFE4F, 0xFF3F, 0xFF65]

## The file this log writes (or tried to write), as a user:// path.
var path: String = ""
## Empty while everything has been written; otherwise what went wrong.
var error_message: String = ""
var rows_written: int = 0
var _file: FileAccess = null


## The tester ID as stored in the CSV and shown on screen: spaces at the ends trimmed
## (ASCII whitespace and EXTRA_EDGE_SPACES), everything else exactly as typed.
static func clean_tester_id(raw: String) -> String:
	var start: int = 0
	var end: int = raw.length()
	while start < end and _is_edge_space(raw.unicode_at(start)):
		start += 1
	while end > start and _is_edge_space(raw.unicode_at(end - 1)):
		end -= 1
	return raw.substr(start, end - start)


static func _is_edge_space(code: int) -> bool:
	return code <= 0x20 or code in EXTRA_EDGE_SPACES


## Empty IDs, or IDs made only of spaces (any of the trimmed kinds), can't start a session.
static func is_tester_id_usable(raw: String) -> bool:
	return not clean_tester_id(raw).is_empty()


## The trimmed ID made safe for a file name: letters of any script with their accents and
## vowel marks (Sơn, Đức stay as they are), digits, '-' and '_' are kept; every other
## character becomes '_', so no path separator, dot, space, joiner or reserved character
## reaches the file system.
static func sanitize_tester_id(raw: String) -> String:
	var trimmed: String = clean_tester_id(raw)
	var out: String = ""
	for i: int in trimmed.length():
		var character: String = trimmed[i]
		out += character if is_file_name_char(character) else "_"
	return out


## One character: '-', '_', a letter (any script), a decimal digit (any script) or a
## combining mark (so decomposed accents and Thai or Indic vowel signs survive).
## Unicode defines identifier characters (XID_Continue) as exactly letters, combining marks,
## decimal digits, connector punctuation and a few Other_ID_Continue characters; so this is
## "an identifier character after 'a'" (digits and marks can't start one) minus the
## NON_LETTER_ID_CHARS list.
static func is_file_name_char(character: String) -> bool:
	if character == "-" or character == "_":
		return true
	return ("a" + character).is_valid_unicode_identifier() \
			and character.unicode_at(0) not in NON_LETTER_ID_CHARS


static func timestamp_now() -> String:
	var t: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]


static func file_name_for(tester_id: String, output_mode: String, timestamp: String) -> String:
	return "%s_%s_%s.csv" % [sanitize_tester_id(tester_id), sanitize_tester_id(output_mode), timestamp]


## `file_name` with _2, _3, ... before the extension until no file in `dir_path` has it.
static func free_path(dir_path: String, file_name: String) -> String:
	var candidate: String = dir_path.path_join(file_name)
	var n: int = 2
	while FileAccess.file_exists(candidate):
		candidate = dir_path.path_join("%s_%d.%s" % [file_name.get_basename(), n, file_name.get_extension()])
		n += 1
	return candidate


## Creates the folder and the file and writes the header. Returns OK or the error.
func open(dir_path: String, tester_id: String, output_mode: String, timestamp: String) -> Error:
	close()
	error_message = ""
	rows_written = 0
	var file_name: String = file_name_for(tester_id, output_mode, timestamp)
	path = dir_path.path_join(file_name)
	var err: Error = DirAccess.make_dir_recursive_absolute(dir_path)
	if err != OK:
		return _fail(err, "could not create the results folder")
	path = free_path(dir_path, file_name)
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		return _fail(FileAccess.get_open_error(), "could not create the results file")
	return _store(PackedStringArray(TrialPlan.CSV_COLUMNS))


## Appends one row and flushes it to disk.
func append_row(row: PackedStringArray) -> Error:
	if _file == null:
		if error_message.is_empty():
			error_message = "results file is not open"
		return ERR_FILE_CANT_WRITE
	var err: Error = _store(row)
	if err == OK:
		rows_written += 1
	return err


func close() -> void:
	if _file != null:
		_file.close()
		_file = null


func has_error() -> bool:
	return not error_message.is_empty()


func global_path() -> String:
	return ProjectSettings.globalize_path(path)


func _store(row: PackedStringArray) -> Error:
	if not _file.store_csv_line(row):
		return _fail(_file.get_error(), "could not write to the results file")
	_file.flush()
	var err: Error = _file.get_error()
	if err != OK:
		return _fail(err, "could not flush the results file")
	return OK


func _fail(err: Error, what: String) -> Error:
	if err == OK:
		err = FAILED
	error_message = "%s (%s)" % [what, error_string(err)]
	push_warning("Ear test: %s: %s" % [error_message, global_path()])
	close()
	return err

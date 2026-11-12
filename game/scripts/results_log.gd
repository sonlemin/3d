## Writes one session to user://ear_test_results/<tester>_<mode>_<timestamp>.csv.
## Every row is flushed as soon as it is written, so a crash mid-session keeps the data.
## A write failure never stops the session: it is recorded in `error_message` and the
## results screen shows it together with the attempted path.
extends RefCounted

const TrialPlan := preload("res://scripts/trial_plan.gd")

const DEFAULT_DIR: String = "user://ear_test_results"

## The file this log writes (or tried to write), as a user:// path.
var path: String = ""
## Empty while everything has been written; otherwise what went wrong.
var error_message: String = ""
var rows_written: int = 0
var _file: FileAccess = null


## Empty or whitespace-only IDs can't start a session.
static func is_tester_id_usable(raw: String) -> bool:
	return not raw.strip_edges().is_empty()


## Keeps ASCII letters, digits, '-' and '_'; every other character becomes '_'.
static func sanitize_tester_id(raw: String) -> String:
	var trimmed: String = raw.strip_edges()
	var out: String = ""
	for i: int in trimmed.length():
		var code: int = trimmed.unicode_at(i)
		var keep: bool = (code >= 0x30 and code <= 0x39) \
				or (code >= 0x41 and code <= 0x5A) \
				or (code >= 0x61 and code <= 0x7A) \
				or code == 0x2D or code == 0x5F
		out += trimmed[i] if keep else "_"
	return out


static func timestamp_now() -> String:
	var t: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]


static func file_name_for(tester_id: String, output_mode: String, timestamp: String) -> String:
	return "%s_%s_%s.csv" % [sanitize_tester_id(tester_id), sanitize_tester_id(output_mode), timestamp]


## Creates the folder and the file and writes the header. Returns OK or the error.
func open(dir_path: String, tester_id: String, output_mode: String, timestamp: String) -> Error:
	close()
	error_message = ""
	rows_written = 0
	path = dir_path.path_join(file_name_for(tester_id, output_mode, timestamp))
	var err: Error = DirAccess.make_dir_recursive_absolute(dir_path)
	if err != OK:
		return _fail(err, "could not create the results folder")
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

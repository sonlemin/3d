extends SceneTree
## Decodes compressed audio to 16-bit stereo WAV, offline (no playback, no audio device):
##
##     godot --headless --path game -s res://tools/decode_audio.gd -- /abs/in.ogg /abs/out.wav ...
##
## Arguments come in pairs: an .ogg or .mp3 source and the .wav to write. Use absolute paths,
## because --path changes the working directory. Output is at the engine's mix rate (44100 Hz).
## tools/cut_cries.py calls this for compressed sources; it isn't needed for WAV sources.


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var failed: int = 0
	for i: int in range(0, args.size() - 1, 2):
		if not decode(args[i], args[i + 1]):
			failed += 1
	quit(1 if failed > 0 or args.size() % 2 != 0 else 0)


func decode(source: String, target: String) -> bool:
	var stream: AudioStream = null
	match source.get_extension().to_lower():
		"ogg":
			stream = AudioStreamOggVorbis.load_from_file(source)
		"mp3":
			stream = AudioStreamMP3.load_from_file(source)
	if stream == null:
		printerr("decode_audio: can't read %s (only .ogg and .mp3)" % source)
		return false
	var rate: int = int(AudioServer.get_mix_rate())
	var total: int = int(ceil(stream.get_length() * rate))
	var playback: AudioStreamPlayback = stream.instantiate_playback()
	playback.start(0.0)
	var pcm: PackedByteArray = PackedByteArray()
	pcm.resize(total * 4)
	var done: int = 0
	while done < total:
		var frames: PackedVector2Array = playback.mix_audio(1.0, mini(4096, total - done))
		if frames.is_empty():
			break  # streams can end a few frames before get_length() says
		for frame: Vector2 in frames:
			pcm.encode_s16(done * 4, int(clampf(frame.x, -1.0, 1.0) * 32767.0))
			pcm.encode_s16(done * 4 + 2, int(clampf(frame.y, -1.0, 1.0) * 32767.0))
			done += 1
	pcm.resize(done * 4)
	var wav: FileAccess = FileAccess.open(target, FileAccess.WRITE)
	if wav == null:
		printerr("decode_audio: can't write %s" % target)
		return false
	wav.store_buffer("RIFF".to_ascii_buffer())
	wav.store_32(36 + pcm.size())
	wav.store_buffer("WAVEfmt ".to_ascii_buffer())
	wav.store_32(16)
	wav.store_16(1)  # PCM
	wav.store_16(2)  # stereo
	wav.store_32(rate)
	wav.store_32(rate * 4)
	wav.store_16(4)
	wav.store_16(16)
	wav.store_buffer("data".to_ascii_buffer())
	wav.store_32(pcm.size())
	wav.store_buffer(pcm)
	wav.close()
	print("decode_audio: %s -> %s (%.2f s)" % [source.get_file(), target.get_file(), float(done) / rate])
	return true

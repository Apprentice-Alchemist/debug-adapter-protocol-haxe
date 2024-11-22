package adapter;

import protocol.Protocol;
import haxe.Json;
import haxe.io.Output;
import haxe.io.Input;

using StringTools;

class ProtocolServer {
	public static var TWO_CRLF = "\r\n\r\n";

	final input:Input;
	final output:Output;

	public function new(input:haxe.io.Input, output:haxe.io.Output) {
		this.input = input;
		this.output = output;
		var contentLength = -1;
		var currentData = haxe.io.Bytes.alloc(0);

		while (true) {
			final newData = input.readAll();

			final _currentData = haxe.io.Bytes.alloc(currentData.length + newData.length);
			_currentData.blit(0, currentData, 0, currentData.length);
			_currentData.blit(currentData.length, newData, 0, newData.length);
			currentData = _currentData;
			if (contentLength >= 0) {
				if (currentData.length >= contentLength) {
					final message = currentData.getString(0, contentLength, UTF8);
					currentData = currentData.sub(contentLength, currentData.length - contentLength);
					if (message.length > 0) {
						try {
							final message:ProtocolMessage = Json.parse(message);
							this.handleMessage(message);
						} catch (e) {
							// 
						}
					}
				}
			} else {
				final curData = currentData.getString(0, currentData.length, UTF8);
				final idx = curData.indexOf(TWO_CRLF);
				if (idx >= 0) {
					final header = curData.substring(0, idx);
					final lines = header.split("\r\n");
					for (line in lines) {
						final pair = line.split(":");
						if (pair[0].trim() == "Content-Length") {
							contentLength = Std.parseInt(pair[1].trim());
						}
					}
				}
			}
		}
	}

	function handleMessage(m:ProtocolMessage) {}
}

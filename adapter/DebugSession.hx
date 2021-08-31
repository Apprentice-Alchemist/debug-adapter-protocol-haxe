package adapter;
import protocol.Protocol;
import protocol.Protocol;
class DebugSession /*extends ProtocolServer*/ {

	private var _debuggerLinesStartAt1: Bool;
	private var _debuggerColumnsStartAt1: Bool;
	private var _debuggerPathsAreURIs: Bool;

	private var _clientLinesStartAt1: Bool;
	private var _clientColumnsStartAt1: Bool;
	private var _clientPathsAreURIs: Bool;

	var _isServer: Bool;

	public function new() {
		// super();

		final linesAndColumnsStartAt1 = false;
		this._debuggerLinesStartAt1 = linesAndColumnsStartAt1;
		this._debuggerColumnsStartAt1 = linesAndColumnsStartAt1;
		this._debuggerPathsAreURIs = false;

		this._clientLinesStartAt1 = true;
		this._clientColumnsStartAt1 = true;
		this._clientPathsAreURIs = false;

		this._isServer = false;

		// this.on('close', () => {
		// 	this.shutdown();
		// });
		// this.on('error', (error) => {
		// 	this.shutdown();
		// });
	}
	function sendResponse(r) {}
	public function setDebuggerPathFormat(format:String) {
		this._debuggerPathsAreURIs = format != 'path';
	}

	public function setDebuggerLinesStartAt1(enable: Bool) {
		this._debuggerLinesStartAt1 = enable;
	}

	public function setDebuggerColumnsStartAt1(enable: Bool) {
		this._debuggerColumnsStartAt1 = enable;
	}

	public function setRunAsServer(enable: Bool) {
		this._isServer = enable;
	}

	/**
	 * A virtual finalructor...
	 */
	public static function run(debugSession: Class<DebugSession>) {
		// runDebugAdapter(debugSession);
	}

	public function shutdown():Void {
		// if (this._isServer || this._isRunningInline()) {
		// 	// shutdown ignored in server mode
		// } else {
		// 	// wait a bit before shutting down
		// 	setTimeout(() => {
		// 		process.exit(0);
		// 	}, 100);
		// }
	}

	function sendErrorResponse<T>(response: Response<T>, codeOrMessage: haxe.ds.Either<Int, Message>, ?format:String, ?variables:Any/*, dest: ErrorDestination = ErrorDestination.User*/):Void {

		// let msg : Message;
		// if (typeof codeOrMessage == 'number') {
		// 	msg = <Message> {
		// 		id: <number> codeOrMessage,
		// 		format: format
		// 	};
		// 	if (variables) {
		// 		msg.variables = variables;
		// 	}
		// 	if (dest & ErrorDestination.User) {
		// 		msg.showUser = true;
		// 	}
		// 	if (dest & ErrorDestination.Telemetry) {
		// 		msg.sendTelemetry = true;
		// 	}
		// } else {
		// 	msg = codeOrMessage;
		// }

		// response.success = false;
		// response.message = DebugSession.formatPII(msg.format, true, msg.variables);
		// if (!response.body) {
		// 	response.body = { };
		// }
		// response.body.error = msg;

		// this.sendResponse(response);
	}

	public function runInTerminalRequest(args: RunInTerminalRequestArguments, timeout:Int, cb: (response: RunInTerminalResponse) -> Void) {
		// this.sendRequest('runInTerminal', args, timeout, cb);
	}

	function dispatchRequest<T>(request: Request<T>):Void {

		final response = new Response(request);

		try {
			if (request.command == 'initialize') {
				var args:InitializeRequestArguments = request.arguments;

				// if (typeof args.linesStartAt1 == 'Bool') {
				// 	this._clientLinesStartAt1 = args.linesStartAt1;
				// }
				// if (typeof args.columnsStartAt1 == 'Bool') {
				// 	this._clientColumnsStartAt1 = args.columnsStartAt1;
				// }

				if (args.pathFormat != 'path') {
					this.sendErrorResponse(response, 2018, 'debug adapter only supports native paths', null, ErrorDestination.Telemetry);
				} else {
					final initializeResponse = (cast response:InitializeResponse);
					initializeResponse.body = {};
					this.initializeRequest(initializeResponse, args);
				}

			} else if (request.command == 'launch') {
				this.launchRequest((cast response:LaunchResponse), request.arguments, request);

			} else if (request.command == 'attach') {
				this.attachRequest((cast response:AttachResponse), request.arguments, request);

			} else if (request.command == 'disconnect') {
				this.disconnectRequest((cast response:DisconnectResponse), request.arguments, request);

			} else if (request.command == 'terminate') {
				this.terminateRequest((cast response:TerminateResponse), request.arguments, request);

			} else if (request.command == 'restart') {
				this.restartRequest((cast response:RestartResponse), request.arguments, request);

			} else if (request.command == 'setBreakpoints') {
				this.setBreakPointsRequest((cast response:SetBreakpointsResponse), request.arguments, request);

			} else if (request.command == 'setFunctionBreakpoints') {
				this.setFunctionBreakPointsRequest((cast response:SetFunctionBreakpointsResponse), request.arguments, request);

			} else if (request.command == 'setExceptionBreakpoints') {
				this.setExceptionBreakPointsRequest((cast response:SetExceptionBreakpointsResponse), request.arguments, request);

			} else if (request.command == 'configurationDone') {
				this.configurationDoneRequest((cast response:ConfigurationDoneResponse), request.arguments, request);

			} else if (request.command == 'continue') {
				this.continueRequest((cast response:ContinueResponse), request.arguments, request);

			} else if (request.command == 'next') {
				this.nextRequest((cast response:NextResponse), request.arguments, request);

			} else if (request.command == 'stepIn') {
				this.stepInRequest((cast response:StepInResponse), request.arguments, request);

			} else if (request.command == 'stepOut') {
				this.stepOutRequest((cast response:StepOutResponse), request.arguments, request);

			} else if (request.command == 'stepBack') {
				this.stepBackRequest((cast response:StepBackResponse), request.arguments, request);

			} else if (request.command == 'reverseContinue') {
				this.reverseContinueRequest((cast response:ReverseContinueResponse), request.arguments, request);

			} else if (request.command == 'restartFrame') {
				this.restartFrameRequest((cast response:RestartFrameResponse), request.arguments, request);

			} else if (request.command == 'goto') {
				this.gotoRequest((cast response:GotoResponse), request.arguments, request);

			} else if (request.command == 'pause') {
				this.pauseRequest((cast response:PauseResponse), request.arguments, request);

			} else if (request.command == 'stackTrace') {
				this.stackTraceRequest((cast response:StackTraceResponse), request.arguments, request);

			} else if (request.command == 'scopes') {
				this.scopesRequest((cast response:ScopesResponse), request.arguments, request);

			} else if (request.command == 'variables') {
				this.variablesRequest((cast response:VariablesResponse), request.arguments, request);

			} else if (request.command == 'setVariable') {
				this.setVariableRequest((cast response:SetVariableResponse), request.arguments, request);

			} else if (request.command == 'setExpression') {
				this.setExpressionRequest((cast response:SetExpressionResponse), request.arguments, request);

			} else if (request.command == 'source') {
				this.sourceRequest((cast response:SourceResponse), request.arguments, request);

			} else if (request.command == 'threads') {
				this.threadsRequest((cast response:ThreadsResponse), request);

			} else if (request.command == 'terminateThreads') {
				this.terminateThreadsRequest((cast response:TerminateThreadsResponse), request.arguments, request);

			} else if (request.command == 'evaluate') {
				this.evaluateRequest((cast response:EvaluateResponse), request.arguments, request);

			} else if (request.command == 'stepInTargets') {
				this.stepInTargetsRequest((cast response:StepInTargetsResponse), request.arguments, request);

			} else if (request.command == 'gotoTargets') {
				this.gotoTargetsRequest((cast response:GotoTargetsResponse), request.arguments, request);

			} else if (request.command == 'completions') {
				this.completionsRequest((cast response:CompletionsResponse), request.arguments, request);

			} else if (request.command == 'exceptionInfo') {
				this.exceptionInfoRequest((cast response:ExceptionInfoResponse), request.arguments, request);

			} else if (request.command == 'loadedSources') {
				this.loadedSourcesRequest((cast response:LoadedSourcesResponse), request.arguments, request);

			} else if (request.command == 'dataBreakpointInfo') {
				this.dataBreakpointInfoRequest((cast response:DataBreakpointInfoResponse), request.arguments, request);

			} else if (request.command == 'setDataBreakpoints') {
				this.setDataBreakpointsRequest((cast response:SetDataBreakpointsResponse), request.arguments, request);

			} else if (request.command == 'readMemory') {
				this.readMemoryRequest((cast response:ReadMemoryResponse), request.arguments, request);

			} else if (request.command == 'writeMemory') {
				this.writeMemoryRequest((cast response:WriteMemoryResponse), request.arguments, request);

			} else if (request.command == 'disassemble') {
				this.disassembleRequest((cast response:DisassembleResponse), request.arguments, request);

			} else if (request.command == 'cancel') {
				this.cancelRequest((cast response:CancelResponse), request.arguments, request);

			} else if (request.command == 'breakpointLocations') {
				this.breakpointLocationsRequest((cast response:BreakpointLocationsResponse), request.arguments, request);

			} else if (request.command == 'setInstructionBreakpoints') {
				this.setInstructionBreakpointsRequest((cast response:SetInstructionBreakpointsResponse), request.arguments, request);

			} else {
				this.customRequest(request.command, (cast response:Response), request.arguments, request);
			}
		} catch (e) {
			this.sendErrorResponse(response, 1104, '{_stack}', { _exception: e.message, _stack: e.stack }, ErrorDestination.Telemetry);
		}
	}

	function initializeRequest(response: InitializeResponse, args: InitializeRequestArguments):Void {

		// This default debug adapter does not support conditional breakpoints.
		response.body.supportsConditionalBreakpoints = false;

		// This default debug adapter does not support hit conditional breakpoints.
		response.body.supportsHitConditionalBreakpoints = false;

		// This default debug adapter does not support function breakpoints.
		response.body.supportsFunctionBreakpoints = false;

		// This default debug adapter implements the 'configurationDone' request.
		response.body.supportsConfigurationDoneRequest = true;

		// This default debug adapter does not support hovers based on the 'evaluate' request.
		response.body.supportsEvaluateForHovers = false;

		// This default debug adapter does not support the 'stepBack' request.
		response.body.supportsStepBack = false;

		// This default debug adapter does not support the 'setVariable' request.
		response.body.supportsSetVariable = false;

		// This default debug adapter does not support the 'restartFrame' request.
		response.body.supportsRestartFrame = false;

		// This default debug adapter does not support the 'stepInTargets' request.
		response.body.supportsStepInTargetsRequest = false;

		// This default debug adapter does not support the 'gotoTargets' request.
		response.body.supportsGotoTargetsRequest = false;

		// This default debug adapter does not support the 'completions' request.
		response.body.supportsCompletionsRequest = false;

		// This default debug adapter does not support the 'restart' request.
		response.body.supportsRestartRequest = false;

		// This default debug adapter does not support the 'exceptionOptions' attribute on the 'setExceptionBreakpoints' request.
		response.body.supportsExceptionOptions = false;

		// This default debug adapter does not support the 'format' attribute on the 'variables', 'evaluate', and 'stackTrace' request.
		response.body.supportsValueFormattingOptions = false;

		// This debug adapter does not support the 'exceptionInfo' request.
		response.body.supportsExceptionInfoRequest = false;

		// This debug adapter does not support the 'TerminateDebuggee' attribute on the 'disconnect' request.
		response.body.supportTerminateDebuggee = false;

		// This debug adapter does not support delayed loading of stack frames.
		response.body.supportsDelayedStackTraceLoading = false;

		// This debug adapter does not support the 'loadedSources' request.
		response.body.supportsLoadedSourcesRequest = false;

		// This debug adapter does not support the 'logMessage' attribute of the SourceBreakpoint.
		response.body.supportsLogPoints = false;

		// This debug adapter does not support the 'terminateThreads' request.
		response.body.supportsTerminateThreadsRequest = false;

		// This debug adapter does not support the 'setExpression' request.
		response.body.supportsSetExpression = false;

		// This debug adapter does not support the 'terminate' request.
		response.body.supportsTerminateRequest = false;

		// This debug adapter does not support data breakpoints.
		response.body.supportsDataBreakpoints = false;

		/** This debug adapter does not support the 'readMemory' request. */
		response.body.supportsReadMemoryRequest = false;

		/** The debug adapter does not support the 'disassemble' request. */
		response.body.supportsDisassembleRequest = false;

		/** The debug adapter does not support the 'cancel' request. */
		response.body.supportsCancelRequest = false;

		/** The debug adapter does not support the 'breakpointLocations' request. */
		response.body.supportsBreakpointLocationsRequest = false;

		/** The debug adapter does not support the 'clipboard' context value in the 'evaluate' request. */
		response.body.supportsClipboardContext = false;

		/** The debug adapter does not support stepping granularities for the stepping requests. */
		response.body.supportsSteppingGranularity = false;

		/** The debug adapter does not support the 'setInstructionBreakpoints' request. */
		response.body.supportsInstructionBreakpoints = false;

		/** The debug adapter does not support 'filterOptions' on the 'setExceptionBreakpoints' request. */
		response.body.supportsExceptionFilterOptions = false;

		this.sendResponse(response);
	}

	function disconnectRequest(response: DisconnectResponse, args: DisconnectArguments, ?request: DisconnectRequest):Void {
		this.sendResponse(response);
		this.shutdown();
	}

	function launchRequest(response: LaunchResponse, args: LaunchRequestArguments, ?request: LaunchRequest):Void {
		this.sendResponse(response);
	}

	function attachRequest(response: AttachResponse, args: AttachRequestArguments, ?request: AttachRequest):Void {
		this.sendResponse(response);
	}

	function terminateRequest(response: TerminateResponse, args: TerminateArguments, ?request: TerminateRequest):Void {
		this.sendResponse(response);
	}

	function restartRequest(response: RestartResponse, args: RestartArguments, ?request: RestartRequest):Void {
		this.sendResponse(response);
	}

	function setBreakPointsRequest(response: SetBreakpointsResponse, args: SetBreakpointsArguments, ?request: SetBreakpointsRequest):Void {
		this.sendResponse(response);
	}

	function setFunctionBreakPointsRequest(response: SetFunctionBreakpointsResponse, args: SetFunctionBreakpointsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function setExceptionBreakPointsRequest(response: SetExceptionBreakpointsResponse, args: SetExceptionBreakpointsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function configurationDoneRequest(response: ConfigurationDoneResponse, args: ConfigurationDoneArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function continueRequest(response: ContinueResponse, args: ContinueArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function nextRequest(response: NextResponse, args: NextArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function stepInRequest(response: StepInResponse, args: StepInArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function stepOutRequest(response: StepOutResponse, args: StepOutArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function stepBackRequest(response: StepBackResponse, args: StepBackArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function reverseContinueRequest(response: ReverseContinueResponse, args: ReverseContinueArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function restartFrameRequest(response: RestartFrameResponse, args: RestartFrameArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function gotoRequest(response: GotoResponse, args: GotoArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function pauseRequest(response: PauseResponse, args: PauseArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function sourceRequest(response: SourceResponse, args: SourceArguments, ?request: Request) :Void {
		this.sendResponse(response);
	}

	function threadsRequest(response: ThreadsResponse, ?request: Request):Void {
		this.sendResponse(response);
	}

	function terminateThreadsRequest(response: TerminateThreadsResponse, args: TerminateThreadsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function stackTraceRequest(response: StackTraceResponse, args: StackTraceArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function scopesRequest(response: ScopesResponse, args: ScopesArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function variablesRequest(response: VariablesResponse, args: VariablesArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function setVariableRequest(response: SetVariableResponse, args: SetVariableArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function setExpressionRequest(response: SetExpressionResponse, args: SetExpressionArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function evaluateRequest(response: EvaluateResponse, args: EvaluateArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function stepInTargetsRequest(response: StepInTargetsResponse, args: StepInTargetsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function gotoTargetsRequest(response: GotoTargetsResponse, args: GotoTargetsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function completionsRequest(response: CompletionsResponse, args: CompletionsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function exceptionInfoRequest(response: ExceptionInfoResponse, args: ExceptionInfoArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function loadedSourcesRequest(response: LoadedSourcesResponse, args: LoadedSourcesArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function dataBreakpointInfoRequest(response: DataBreakpointInfoResponse, args: DataBreakpointInfoArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function setDataBreakpointsRequest(response: SetDataBreakpointsResponse, args: SetDataBreakpointsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function readMemoryRequest(response: ReadMemoryResponse, args: ReadMemoryArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function writeMemoryRequest(response: WriteMemoryResponse, args: WriteMemoryArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function disassembleRequest(response: DisassembleResponse, args: DisassembleArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function cancelRequest(response: CancelResponse, args: CancelArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function breakpointLocationsRequest(response: BreakpointLocationsResponse, args: BreakpointLocationsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	function setInstructionBreakpointsRequest(response: SetInstructionBreakpointsResponse, args: SetInstructionBreakpointsArguments, ?request: Request):Void {
		this.sendResponse(response);
	}

	/**
	 * Override this hook to implement custom requests.
	 */
	function customRequest(command:String, response: Response, args: Any, ?request: Request):Void {
		// this.sendErrorResponse(response, 1014, 'unrecognized request', null, ErrorDestination.Telemetry);
	}

	//---- protected -------------------------------------------------------------------------------------------------

	function convertClientLineToDebugger(line:Int):Int {
		if (this._debuggerLinesStartAt1) {
			return this._clientLinesStartAt1 ? line : line + 1;
		}
		return this._clientLinesStartAt1 ? line - 1 : line;
	}

	function convertDebuggerLineToClient(line:Int):Int {
		if (this._debuggerLinesStartAt1) {
			return this._clientLinesStartAt1 ? line : line - 1;
		}
		return this._clientLinesStartAt1 ? line + 1 : line;
	}

	function convertClientColumnToDebugger(column:Int):Int {
		if (this._debuggerColumnsStartAt1) {
			return this._clientColumnsStartAt1 ? column : column + 1;
		}
		return this._clientColumnsStartAt1 ? column - 1 : column;
	}

	function convertDebuggerColumnToClient(column:Int):Int {
		if (this._debuggerColumnsStartAt1) {
			return this._clientColumnsStartAt1 ? column : column - 1;
		}
		return this._clientColumnsStartAt1 ? column + 1 : column;
	}

	function convertClientPathToDebugger(clientPath:String):String {
		// if (this._clientPathsAreURIs != this._debuggerPathsAreURIs) {
		// 	if (this._clientPathsAreURIs) {
		// 		return DebugSession.uri2path(clientPath);
		// 	} else {
		// 		return DebugSession.path2uri(clientPath);
		// 	}
		// }
		return clientPath;
	}

	function convertDebuggerPathToClient(debuggerPath:String):String {
		// if (this._debuggerPathsAreURIs != this._clientPathsAreURIs) {
		// 	if (this._debuggerPathsAreURIs) {
		// 		return DebugSession.uri2path(debuggerPath);
		// 	} else {
		// 		return DebugSession.path2uri(debuggerPath);
		// 	}
		// }
		return debuggerPath;
	}

	//---- private -------------------------------------------------------------------------------

	// private static function path2uri(path:String):String {

	// 	if (process.platform == 'win32') {
	// 		if (/^[A-Z]:/.test(path)) {
	// 			path = path[0].toLowerCase() + path.substr(1);
	// 		}
	// 		// path = path.replace(/\\/g, '/');
	// 	}
	// 	path = encodeURI(path);

	// 	// let uri = new URL(`file:`);	// ignore 'path' for now
	// 	uri.pathname = path;	// now use 'path' to get the correct percent encoding (see https://url.spec.whatwg.org)
	// 	return uri.toString();
	// }

	// private static uri2path(sourceUri:String):String {

	// 	let uri = new URL(sourceUri);
	// 	let s = decodeURIComponent(uri.pathname);
	// 	if (process.platform == 'win32') {
	// 		// if (/^\/[a-zA-Z]:/.test(s)) {
	// 		// 	s = s[1].toLowerCase() + s.substr(2);
	// 		// }
	// 		// s = s.replace(/\//g, '\\');
	// 	}
	// 	return s;
	// }

	// private static _formatPIIRegexp = /{([^}]+)}/g;

	// /*
	// * If argument starts with '_' it is OK to send its value to telemetry.
	// */
	// private static formatPII(format:string, excludePII: Bool, args: {[key:String]:String}):String {
	// 	return format.replace(DebugSession._formatPIIRegexp, function(match, paramName) {
	// 		if (excludePII && paramName.length > 0 && paramName[0] != '_') {
	// 			return match;
	// 		}
	// 		return args[paramName] && args.hasOwnProperty(paramName) ?
	// 			args[paramName] :
	// 			match;
	// 	})
	// }
}
package protocol;

enum abstract ProtocolMessageType(String) {
	var request;
	var response;
	var event;
}

typedef ProtocolMessage = {
	/**
	 * Sequence number (also known as message ID). For protocol messages of type
	 * 'request' this ID can be used to cancel the request.
	 */
	var seq:Int;

	/**
	 * Message type.
	 * Values: 'request', 'response', 'event', etc.
	 */
	var type:ProtocolMessageType;
}

typedef Request<A:{}> = ProtocolMessage & {
	/**
	 * The command to execute.
	 */
	var command:String;

	/**
	 * Object containing arguments for the command.
	 */
	var ?arguments:A;
}

typedef Event<T:{}> = ProtocolMessage & {
	/**
	 * Type of event.
	 */
	var event:EventType<Event<{}>>;

	/**
	 * Event-specific information.
	 */
	var ?body:T;
}

typedef Response<T:{}> = ProtocolMessage & {
	/**
	 * Sequence number of the corresponding request.
	 */
	var request_seq:Int;

	/**
	 * Outcome of the request.
	 * If true, the request was successful and the 'body' attribute may contain
	 * the result of the request.
	 * If the value is false, the attribute 'message' contains the error in short
	 * form and the 'body' may contain additional information (see
	 * 'ErrorResponse.body.error').
	 */
	var success:Bool;

	/**
	 * The command requested.
	 */
	var command:String;

	/**
	 * Contains the raw error in short form if 'success' is false.
	 * This raw error might be interpreted by the frontend and is not shown in the
	 * UI.
	 * Some predefined values exist.
	 * Values: 
	 * 'cancelled': request was cancelled.
	 * etc.
	 */
	var ?message:String;

	/**
	 * Contains request result if success is true and optional error details if
	 * success is false.
	 */
	var ?body:T;
}

enum abstract RequestType<T>(String) {
	var cancel:RequestType<CancelRequest>;
	// var runInTerminal:RequestType<RunInTerminalRequest>;
	// var initialize:RequestType<InitializeRequest>;
}

/**
	The ‘cancel’ request is used by the frontend in two situations:

		- to indicate that it is no longer interested in the result produced by a specific request issued earlier
		- to cancel a progress sequence. Clients should only call this request if the capability ‘supportsCancelRequest’ is true.

	This request has a hint characteristic: a debug adapter can only be expected to make a ‘best effort’ in honouring this request but there are no guarantees.

	The ‘cancel’ request may return an error if it could not cancel an operation but a frontend should refrain from presenting this error to end users.

	A frontend client should only call this request if the capability ‘supportsCancelRequest’ is true.

	The request that got canceled still needs to send a response back. This can either be a normal result (‘success’ attribute true)

	or an error response (‘success’ attribute false and the ‘message’ set to ‘cancelled’).

	Returning partial results from a cancelled request is possible but please note that a frontend client has no generic way for detecting that a response is partial or not.

	The progress that got cancelled still needs to send a ‘progressEnd’ event back.

	A client should not assume that progress just got cancelled after sending the ‘cancel’ request.
 */
typedef CancelRequest = Request<CancelArguments>;

typedef CancelResponse = Response<{}>;

typedef CancelArguments = {
	/**
	 * The ID (attribute 'seq') of the request to cancel. If missing no request is
	 * cancelled.
	 * Both a 'requestId' and a 'progressId' can be specified in one request.
	 */
	var ?requestId:Int;

	/**
	 * The ID (attribute 'progressId') of the progress to cancel. If missing no
	 * progress is cancelled.
	 * Both a 'requestId' and a 'progressId' can be specified in one request.
	 */
	var ?progressId:String;
}

/**
	This optional request is sent from the debug adapter to the client to run a command in a terminal.

	This is typically used to launch the debuggee in a terminal provided by the client.

	This request should only be called if the client has passed the value true for the ‘supportsRunInTerminalRequest’ capability of the ‘initialize’ request.
 */
typedef RunInTerminalRequest = Request<RunInTerminalArguments>;

typedef RunInTerminalResponse = Response<{
	/**
	 * The process ID. The value should be less than or equal to 2147483647
	 * (2^31-1).
	 */
	var processId:Int;

	/**
	 * The process ID of the terminal shell. The value should be less than or
	 * equal to 2147483647 (2^31-1).
	 */
	var shellProcessId:Int;
}>;

enum abstract TerminalLaunchKind(String) {
	var integrated;
	var terminal;
}

typedef RunInTerminalArguments = {
	/**
	 * What kind of terminal to launch.
	 * Values: 'integrated', 'external', etc.
	 */
	var ?kind:TerminalLaunchKind;

	/**
	 * Optional title of the terminal.
	 */
	var ?title:String;

	/**
	 * Working directory for the command. For non-empty, valid paths this
	 * typically results in execution of a change directory command.
	 */
	var cwd:String;

	/**
	 * List of arguments. The first argument is the command to run.
	 */
	var args:Array<String>;

	/**
	 * Environment key-value pairs that are added to or removed from the default
	 * environment.
	 */
	var ?env:{};
}

/**
	The ‘initialize’ request is sent as the first request from the client to the debug adapter

	in order to configure it with client capabilities and to retrieve capabilities from the debug adapter.

	Until the debug adapter has responded to with an ‘initialize’ response, the client must not send any additional requests or events to the debug adapter.

	In addition the debug adapter is not allowed to send any requests or events to the client until it has responded with an ‘initialize’ response.

	The ‘initialize’ request may only be sent once.
 */
typedef InitializeRequest = Request<InitializeArguments>;

enum abstract PathFormat(String) {
	var path;
	var uri;
}

typedef InitializeArguments = {
	/**
	 * The ID of the (frontend) client using this adapter.
	 */
	var ?clientID:String;

	/**
	 * The human readable name of the (frontend) client using this adapter.
	 */
	var ?clientName:String;

	/**
	 * The ID of the debug adapter.
	 */
	var adapterID:String;

	/**
	 * The ISO-639 locale of the (frontend) client using this adapter, e.g. en-US
	 * or de-CH.
	 */
	var ?locale:String;

	/**
	 * If true all line numbers are 1-based (default).
	 */
	var ?linesStartAt1:Bool;

	/**
	 * If true all column numbers are 1-based (default).
	 */
	var ?columnsStartAt1:Bool;

	/**
	 * Determines in what format paths are specified. The default is 'path', which
	 * is the native format.
	 * Values: 'path', 'uri', etc.
	 */
	var ?pathFormat:PathFormat;

	/**
	 * Client supports the optional type attribute for variables.
	 */
	var ?supportsVariableType:Bool;

	/**
	 * Client supports the paging of variables.
	 */
	var ?supportsVariablePaging:Bool;

	/**
	 * Client supports the runInTerminal request.
	 */
	var ?supportsRunInTerminalRequest:Bool;

	/**
	 * Client supports memory references.
	 */
	var ?supportsMemoryReferences:Bool;

	/**
	 * Client supports progress reporting.
	 */
	var ?supportsProgressReporting:Bool;

	/**
	 * Client supports the invalidated event.
	 */
	var ?supportsInvalidatedEvent:Bool;

	/**
	 * Client supports the memory event.
	 */
	var ?supportsMemoryEvent:Bool;
}

typedef InitializeResponse = Response<Capabilities>;

/**
	This optional request indicates that the client has finished initialization of the debug adapter.

	So it is the last request in the sequence of configuration requests (which was started by the ‘initialized’ event).

	Clients should only call this request if the capability ‘supportsConfigurationDoneRequest’ is true.
 */
typedef ConfigurationDoneRequest = Request<{}>;

typedef ConfigurationDoneResponse = Response<{}>;

/**
	This launch request is sent from the client to the debug adapter to start the debuggee with or without debugging (if ‘noDebug’ is true).

	Since launching is debugger/runtime specific, the arguments for this request are not part of this specification.
	*
 */
typedef LaunchRequest = Request<LaunchArguments>;

typedef LaunchArguments = {
	/**
	 * If noDebug is true the launch request should launch the program without
	 * enabling debugging.
	 */
	var ?noDebug:Bool;

	/**
	 * Optional data from the previous, restarted session.
	 * The data is sent as the 'restart' attribute of the 'terminated' event.
	 * The client should leave the data intact.
	 */
	var ?__restart:Any;
}

typedef LaunchResponse = Response<{}>;

/**
	The attach request is sent from the client to the debug adapter to attach to a debuggee that is already running.

	Since attaching is debugger/runtime specific, the arguments for this request are not part of this specification.
 */
typedef AttachRequest = Request<AttachArguments>;

typedef AttachArguments = {
	/**
	 * Optional data from the previous, restarted session.
	 * The data is sent as the 'restart' attribute of the 'terminated' event.
	 * The client should leave the data intact.
	 */
	var ?__restart:Any;
}

typedef AttachRequestResponse = Response<{}>;

/**
	Restarts a debug session. Clients should only call this request if the capability ‘supportsRestartRequest’ is true.

	If the capability is missing or has the value false, a typical client will emulate ‘restart’ by terminating the debug adapter first and then launching it anew.
 */
typedef RestartRequest = Request<haxe.extern.EitherType<LaunchArguments, AttachArguments>>;

typedef RestartResponse = Response<{}>;

/**
	The ‘disconnect’ request is sent from the client to the debug adapter in order to stop debugging.

	It asks the debug adapter to disconnect from the debuggee and to terminate the debug adapter.

	If the debuggee has been started with the ‘launch’ request, the ‘disconnect’ request terminates the debuggee.

	If the ‘attach’ request was used to connect to the debuggee, ‘disconnect’ does not terminate the debuggee.

	This behavior can be controlled with the ‘terminateDebuggee’ argument (if supported by the debug adapter).
 */
typedef DisconnectRequest = Request<DisconnectArguments>;

typedef DisconnectArguments = {
	/**
	 * A value of true indicates that this 'disconnect' request is part of a
	 * restart sequence.
	 */
	var ?restart:Bool;

	/**
	 * Indicates whether the debuggee should be terminated when the debugger is
	 * disconnected.
	 * If unspecified, the debug adapter is free to do whatever it thinks is best.
	 * The attribute is only honored by a debug adapter if the capability
	 * 'supportTerminateDebuggee' is true.
	 */
	var ?terminateDebuggee:Bool;

	/**
	 * Indicates whether the debuggee should stay suspended when the debugger is
	 * disconnected.
	 * If unspecified, the debuggee should resume execution.
	 * The attribute is only honored by a debug adapter if the capability
	 * 'supportSuspendDebuggee' is true.
	 */
	var ?suspendDebuggee:Bool;
}

typedef DisconnectResponse = Response<{}>;

/**
	The ‘terminate’ request is sent from the client to the debug adapter in order to give the debuggee a chance for terminating itself.

	Clients should only call this request if the capability ‘supportsTerminateRequest’ is true.
 */
typedef TerminateRequest = Request<TerminateArguments>;

typedef TerminateArguments = {
	/**
	 * A value of true indicates that this 'terminate' request is part of a
	 * restart sequence.
	 */
	var ?restart:Bool;
}

typedef TerminateResponse = Response<{}>;

/**
	The ‘breakpointLocations’ request returns all possible locations for source breakpoints in a given range.

	Clients should only call this request if the capability ‘supportsBreakpointLocationsRequest’ is true.
 */
typedef BreakpointsLocationsRequest = Request<BreakpointsLocationsArguments>;

typedef BreakpointLocationsArguments = {
	/**
	 * The source location of the breakpoints; either 'source.path' or
	 * 'source.reference' must be specified.
	 */
	var source:Source;

	/**
	 * Start line of range to search possible breakpoint locations in. If only the
	 * line is specified, the request returns all possible locations in that line.
	 */
	var line:Int;

	/**
	 * Optional start column of range to search possible breakpoint locations in.
	 * If no start column is given, the first column in the start line is assumed.
	 */
	var ?column:Int;

	/**
	 * Optional end line of range to search possible breakpoint locations in. If
	 * no end line is given, then the end line is assumed to be the start line.
	 */
	var ?endLine:Int;

	/**
	 * Optional end column of range to search possible breakpoint locations in. If
	 * no end column is given, then it is assumed to be in the last column of the
	 * end line.
	 */
	var ?endColumn:Int;
}

typedef BreakpointLocationsResponse = Response<{
	/**
	 * Sorted set of possible breakpoint locations.
	 */
	var breakpoints:Array<BreakpointLocation>;
}>;

enum abstract EventType<T:Event<{}>>(String) {
	var initialized:EventType<InitializedEvent>;
	var stopped:EventType<StoppedEvent>;
	var continued:EventType<ContinuedEvent>;
	var exited:EventType<ExitedEvent>;
	var terminated:EventType<TerminatedEvent>;
	var thread:EventType<ThreadEvent>;
	var output:EventType<OutputEvent>;
	var breakpoint:EventType<BreakpointEvent>;
	var module:EventType<ModuleEvent>;
	var loadedSource:EventType<LoadedSourceEvent>;
	var process:EventType<ProcessEvent>;
	var capabilities:EventType<CapabilitiesEvent>;
	var progressStart:EventType<ProgressStartEvent>;
	var progressUpdate:EventType<ProgressUpdateEvent>;
	var progressEnd:EventType<ProgressEndEvent>;
	var invalidated:EventType<InvalidatedEvent>;
	var memory:EventType<MemoryEvent>;
}

/**
	This event indicates that the debug adapter is ready to accept configuration requests (e.g. SetBreakpointsRequest, SetExceptionBreakpointsRequest).

	A debug adapter is expected to send this event when it is ready to accept configuration requests (but not before the ‘initialize’ request has finished).

	The sequence of events/requests is as follows:

	- adapters sends ‘initialized’ event (after the ‘initialize’ request has returned)
	- frontend sends zero or more ‘setBreakpoints’ requests
	- frontend sends one ‘setFunctionBreakpoints’ request (if capability ‘supportsFunctionBreakpoints’ is true)
	- frontend sends a ‘setExceptionBreakpoints’ request if one or more ‘exceptionBreakpointFilters’ have been defined (or if ‘supportsConfigurationDoneRequest’ is not defined or false)
	- frontend sends other future configuration requests
	- frontend sends one ‘configurationDone’ request to indicate the end of the configuration.

 */
typedef InitializedEvent = Event<{}>;

enum abstract StoppedReason(String) {
	var step = 'step';
	var breakpoint = 'breakpoint';
	var exception = 'exception';
	var pause = 'pause';
	var entry = 'entry';
	var goto = 'goto';
	var functionBreakpoint = 'function breakpoint';
	var dataBreakpoint = 'data breakpoint';
	var instructionBreakpoint = 'instruction breakpoint';
}

/**
	The event indicates that the execution of the debuggee has stopped due to some condition.

	This can be caused by a break point previously set, a stepping request has completed, by executing a debugger statement etc.
 */
typedef StoppedEvent = Event<{
	/**
	 * The reason for the event.
	 * For backward compatibility this string is shown in the UI if the
	 * 'description' attribute is missing (but it must not be translated).
	 * Values: 'step', 'breakpoint', 'exception', 'pause', 'entry', 'goto',
	 * 'function breakpoint', 'data breakpoint', 'instruction breakpoint', etc.
	 */
	var reason:StoppedReason;

	/**
	 * The full reason for the event, e.g. 'Paused on exception'. This string is
	 * shown in the UI as is and must be translated.
	 */
	var ?description:String;

	/**
	 * The thread which was stopped.
	 */
	var ?threadId:Int;

	/**
	 * A value of true hints to the frontend that this event should not change
	 * the focus.
	 */
	var ?preserveFocusHint:Bool;

	/**
	 * Additional information. E.g. if reason is 'exception', text contains the
	 * exception name. This string is shown in the UI.
	 */
	var ?text:String;

	/**
	 * If 'allThreadsStopped' is true, a debug adapter can announce that all
	 * threads have stopped.
	 * - The client should use this information to enable that all threads can
	 * be expanded to access their stacktraces.
	 * - If the attribute is missing or false, only the thread with the given
	 * threadId can be expanded.
	 */
	var ?allThreadsStopped:Bool;

	/**
	 * Ids of the breakpoints that triggered the event. In most cases there will
	 * be only a single breakpoint but here are some examples for multiple
	 * breakpoints:
	 * - Different types of breakpoints map to the same location.
	 * - Multiple source breakpoints get collapsed to the same instruction by
	 * the compiler/runtime.
	 * - Multiple function breakpoints with different function names map to the
	 * same location.
	 */
	var ?hitBreakpointIds:Array<Int>;
}>;

/**
	The event indicates that the execution of the debuggee has continued.

	Please note: a debug adapter is not expected to send this event in response to a request that implies that execution continues, e.g. ‘launch’ or ‘continue’.

	It is only necessary to send a ‘continued’ event if there was no previous request that implied this.
 */
typedef ContinuedEvent = Event<{
	/**
	 * The thread which was continued.
	 */
	var threadId:Int;

	/**
	 * If 'allThreadsContinued' is true, a debug adapter can announce that all
	 * threads have continued.
	 */
	var ?allThreadsContinued:Bool;
}>;

/**
 * The event indicates that the debuggee has exited and returns its exit code.
 */
typedef ExitedEvent = Event<{
	/**
	 * The exit code returned from the debuggee.
	 */
	var exitCode:Int;
}>;

/**
	The event indicates that debugging of the debuggee has terminated. This does **not** mean that the debuggee itself has exited.
 */
typedef TerminatedEvent = Event<{
	/**
	 * A debug adapter may set 'restart' to true (or to an arbitrary object) to
	 * request that the front end restarts the session.
	 * The value is not interpreted by the client and passed unmodified as an
	 * attribute '__restart' to the 'launch' and 'attach' requests.
	 */
	var ?restart:Bool;
}>;

enum abstract ThreadEventReason(String) {
	var started;
	var exited;
}

/**
	The event indicates that a thread has started or exited.
 */
typedef ThreadEvent = Event<{
	/**
	 * The reason for the event.
	 * Values: 'started', 'exited', etc.
	 */
	var reason:ThreadEventReason;

	/**
	 * The identifier of the thread.
	 */
	var threadId:Int;
}>;

enum abstract OutputCategory(String) {
	var console;
	var stdout;
	var stderr;
	var telemetry;
}

enum abstract OutputGroup(String) {
	var start;
	var startCollapsed;
	var end;
}

/**
	The event indicates that the target has produced some output.
 */
typedef OutputEvent = Event<{
	/**
	 * The output category. If not specified, 'console' is assumed.
	 * Values: 'console', 'stdout', 'stderr', 'telemetry', etc.
	 */
	var ?category:OutputCategory;

	/**
	 * The output to report.
	 */
	var output:String;

	/**
	 * Support for keeping an output log organized by grouping related messages.
	 * Values: 
	 * 'start': Start a new group in expanded mode. Subsequent output events are
	 * members of the group and should be shown indented.
	 * The 'output' attribute becomes the name of the group and is not indented.
	 * 'startCollapsed': Start a new group in collapsed mode. Subsequent output
	 * events are members of the group and should be shown indented (as soon as
	 * the group is expanded).
	 * The 'output' attribute becomes the name of the group and is not indented.
	 * 'end': End the current group and decreases the indentation of subsequent
	 * output events.
	 * A non empty 'output' attribute is shown as the unindented end of the
	 * group.
	 * etc.
	 */
	var ?group:OutputGroup;

	/**
	 * If an attribute 'variablesReference' exists and its value is > 0, the
	 * output contains objects which can be retrieved by passing
	 * 'variablesReference' to the 'variables' request. The value should be less
	 * than or equal to 2147483647 (2^31-1).
	 */
	var ?variablesReference:Int;

	/**
	 * An optional source location where the output was produced.
	 */
	var ?source:Source;

	/**
	 * An optional source location line where the output was produced.
	 */
	var ?line:Int;

	/**
	 * An optional source location column where the output was produced.
	 */
	var ?column:Int;

	/**
	 * Optional data to report. For the 'telemetry' category the data will be
	 * sent to telemetry, for the other categories the data is shown in JSON
	 * format.
	 */
	var ?data:Any;
}>;

enum abstract NewChangedRemovedReason(String) {
	var new_ = "new";
	var changed;
	var removed;
}

/**
	The event indicates that some information about a breakpoint has changed.
 */
typedef BreakpointEvent = Event<{
	/**
	 * The reason for the event.
	 * Values: 'changed', 'new', 'removed', etc.
	 */
	var reason:NewChangedRemovedReason;

	/**
	 * The 'id' attribute is used to find the target breakpoint and the other
	 * attributes are used as the new values.
	 */
	var breakpoint:Breakpoint;
}>;

/**
	The event indicates that some information about a module has changed.
 */
typedef ModuleEvent = Event<{
	/**
	 * The reason for the event.
	 * Values: 'new', 'changed', 'removed', etc.
	 */
	var reason:NewChangedRemovedReason;

	/**
	 * The new, changed, or removed module. In case of 'removed' only the module
	 * id is used.
	 */
	var module:Module;
}>;

/**
	The event indicates that some source has been added, changed, or removed from the set of all loaded sources.
 */
typedef LoadedSourceEvent = Event<{
	/**
	 * The reason for the event.
	 * Values: 'new', 'changed', 'removed', etc.
	 */
	var reason:NewChangedRemovedReason;

	/**
	 * The new, changed, or removed source.
	 */
	var source:Source;
}>;

enum abstract ProcessStartMethod(String) {
	var launch;
	var attack;
	var attachForSuspendedLaunch;
}

/**
	The event indicates that the debugger has begun debugging a new process. Either one that it has launched, or one that it has attached to.
 */
typedef ProcessEvent = Event<{
	/**
	 * The logical name of the process. This is usually the full path to
	 * process's executable file. Example: /home/example/myproj/program.js.
	 */
	var name:String;

	/**
	 * The system process id of the debugged process. This property will be
	 * missing for non-system processes.
	 */
	var ?systemProcessId:Int;

	/**
	 * If true, the process is running on the same computer as the debug
	 * adapter.
	 */
	var ?isLocalProcess:Bool;

	/**
	 * Describes how the debug engine started debugging this process.
	 * Values: 
	 * 'launch': Process was launched under the debugger.
	 * 'attach': Debugger attached to an existing process.
	 * 'attachForSuspendedLaunch': A project launcher component has launched a
	 * new process in a suspended state and then asked the debugger to attach.
	 * etc.
	 */
	var ?startMethod:ProcessStartMethod;

	/**
	 * The size of a pointer or address for this process, in bits. This value
	 * may be used by clients when formatting addresses for display.
	 */
	var ?pointerSize:Int;
}>;

/**
	The event indicates that one or more capabilities have changed.

	Since the capabilities are dependent on the frontend and its UI, it might not be possible to change that at random times (or too late).

	Consequently this event has a hint characteristic: a frontend can only be expected to make a ‘best effort’ in honouring individual capabilities but there are no guarantees.

	Only changed capabilities need to be included, all other capabilities keep their values.
	*
 */
typedef CapabilitiesEvent = Event<{
	/**
	 * The set of updated capabilities.
	 */
	var capabilities:Capabilities;
}>;

/**
	The event signals that a long running operation is about to start and

	provides additional information for the client to set up a corresponding progress and cancellation UI.

	The client is free to delay the showing of the UI in order to reduce flicker.

	This event should only be sent if the client has passed the value true for the ‘supportsProgressReporting’ capability of the ‘initialize’ request.
 */
typedef ProgressStartEvent = Event<{
	/**
	 * An ID that must be used in subsequent 'progressUpdate' and 'progressEnd'
	 * events to make them refer to the same progress reporting.
	 * IDs must be unique within a debug session.
	 */
	var progressId:String;

	/**
	 * Mandatory (short) title of the progress reporting. Shown in the UI to
	 * describe the long running operation.
	 */
	var title:String;

	/**
	 * The request ID that this progress report is related to. If specified a
	 * debug adapter is expected to emit
	 * progress events for the long running request until the request has been
	 * either completed or cancelled.
	 * If the request ID is omitted, the progress report is assumed to be
	 * related to some general activity of the debug adapter.
	 */
	var ?requestId:Int;

	/**
	 * If true, the request that reports progress may be canceled with a
	 * 'cancel' request.
	 * So this property basically controls whether the client should use UX that
	 * supports cancellation.
	 * Clients that don't support cancellation are allowed to ignore the
	 * setting.
	 */
	var ?cancellable:Bool;

	/**
	 * Optional, more detailed progress message.
	 */
	var ?message:String;

	/**
	 * Optional progress percentage to display (value range: 0 to 100). If
	 * omitted no percentage will be shown.
	 */
	var ?percentage:Int;
}>;

/**
	The event signals that the progress reporting needs to updated with a new message and/or percentage.

	The client does not have to update the UI immediately, but the clients needs to keep track of the message and/or percentage values.

	This event should only be sent if the client has passed the value true for the ‘supportsProgressReporting’ capability of the ‘initialize’ request.
 */
typedef ProgressUpdateEvent = Event<{
	/**
	 * The ID that was introduced in the initial 'progressStart' event.
	 */
	var progressId:String;

	/**
	 * Optional, more detailed progress message. If omitted, the previous
	 * message (if any) is used.
	 */
	var ?message:String;

	/**
	 * Optional progress percentage to display (value range: 0 to 100). If
	 * omitted no percentage will be shown.
	 */
	var ?percentage:Int;
}>;

/**
	The event signals the end of the progress reporting with an optional final message.

	This event should only be sent if the client has passed the value true for the ‘supportsProgressReporting’ capability of the ‘initialize’ request.
 */
typedef ProgressEndEvent = Event<{
	/**
	 * The ID that was introduced in the initial 'ProgressStartEvent'.
	 */
	var progressId:String;

	/**
	 * Optional, more detailed progress message. If omitted, the previous
	 * message (if any) is used.
	 */
	var ?message:String;
}>;

/**
	This event signals that some state in the debug adapter has changed and requires that the client needs to re-render the data snapshot previously requested.

	Debug adapters do not have to emit this event for runtime changes like stopped or thread events because in that case the client refetches the new state anyway. But the event can be used for example to refresh the UI after rendering formatting has changed in the debug adapter.

	This event should only be sent if the debug adapter has received a value true for the ‘supportsInvalidatedEvent’ capability of the ‘initialize’ request.
 */
typedef InvalidatedEvent = Event<{
	/**
	 * Optional set of logical areas that got invalidated. This property has a
	 * hint characteristic: a client can only be expected to make a 'best
	 * effort' in honouring the areas but there are no guarantees. If this
	 * property is missing, empty, or if values are not understand the client
	 * should assume a single value 'all'.
	 */
	var areas:Array<InvalidatedAreas>;

	/**
	 * If specified, the client only needs to refetch data related to this
	 * thread.
	 */
	var threadId:Int;

	/**
	 * If specified, the client only needs to refetch data related to this stack
	 * frame (and the 'threadId' is ignored).
	 */
	var stackFrameId:Int;
}>;

/**
	This event indicates that some memory range has been updated. It should only be sent if the debug adapter has received a value true for the `supportsMemoryEvent` capability of the `initialize` request.

	Clients typically react to the event by re-issuing a `readMemory` request if they show the memory identified by the `memoryReference` and if the updated memory range overlaps the displayed range. Clients should not make assumptions how individual memory references relate to each other, so they should not assume that they are part of a single continuous address range and might overlap.

	Debug adapters can use this event to indicate that the contents of a memory range has changed due to some other DAP request like `setVariable` or `setExpression`. Debug adapters are not expected to emit this event for each and every memory change of a running program, because that information is typically not available from debuggers and it would flood clients with too many events.
 */
typedef MemoryEvent = Event<{
	/**
	 * Memory reference of a memory range that has been updated.
	 */
	var memoryReference:String;

	/**
	 * Starting offset in bytes where memory has been updated. Can be negative.
	 */
	var offset:Int;

	/**
	 * Number of bytes updated.
	 */
	var count:Int;
}>;

%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the polish application.

-module({{appid}}_inets).

-export([start_link/0, stop/0, do/1, out/1]).

-include_lib("nitrogen/include/wf.hrl").
-include_lib("yaws/include/yaws.hrl").


%%% @doc This is the routing table.
routes() ->
    [{"/",            {{appid}}_web_index}
     , {"/login",     {{appid}}_web_login}
     , {"/logout",    {{appid}}_web_logout}
     , {"/auth",      {{appid}}_web_auth}
     , {"/ajax",      {{appid}}_web_ajax}
     , {"/nitrogen",  static_file}
     , {"/js",        static_file}
     , {"/css",       static_file}
    ].

start_link() ->
    start_link({{appid}}:http_server()).

start_link(inets) ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port,           {{appid}}:port()}
                     ,{server_name,   {{appid}}:servername()}
	             ,{bind_address,  {{appid}}:ip()}
                     ,{server_root,   "."}
                     ,{document_root, {{appid}}:docroot()}
                     ,{modules,       [?MODULE]}
                     ,{mime_types,    [{"css",  "text/css"},
                                       {"js",   "text/javascript"},
                                       {"html", "text/html"}]}
                    ]),
    link(Pid),
    {ok, Pid};

start_link(mochiweb) ->
    mochiweb:start(),
    Options = [{port,   {{appid}}:port()}
               ,{name,  {{appid}}:servername()}
               ,{ip,    {{appid}}:ip()}
               ,{loop,  fun(Req) -> do_mochiweb(Req) end}
              ],
    {ok, Pid} = mochiweb_http:start(Options),
    link(Pid),
    {ok, Pid};

start_link(yaws) ->
    	SC = #sconf {
		appmods     = [{"/", ?MODULE}],
		docroot     = {{appid}}:docroot(),
		port        = {{appid}}:port(),
		servername  = {{appid}}:servername(),
		listen      = {{appid}}:ip()
	},
	DefaultGC = yaws_config:make_default_gconf(false, {{appid}}),
	GC = DefaultGC#gconf {
		logdir = {{appid}}:log_dir(),
		cache_refresh_secs = 5
	},
	% Following code adopted from yaws:start_embedded/4. 
	% This will need to change if Yaws changes!!!
	ok = application:set_env(yaws, embedded, true),
	{ok, Pid} = yaws_sup:start_link(),
	yaws_config:add_yaws_soap_srv(GC),
	SCs = yaws_config:add_yaws_auth([SC]),
	yaws_api:setconf(GC, [SCs]),
	{ok, Pid}.


stop() ->
    httpd:stop_service({any, {{appid}}_deps:get_env(port, {{appid}}:default_port())}),
    ok.

do(Info) ->
    RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    replace_route_handler(),
    nitrogen:run().

out(Info) ->
    RequestBridge = simple_bridge:make_request(yaws_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(yaws_response_bridge, Info),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    replace_route_handler(),
    nitrogen:run().

do_mochiweb(Info) ->
    RequestBridge = simple_bridge:make_request(mochiweb_request_bridge, {Info,"./www"}),
    ResponseBridge = simple_bridge:make_response(mochiweb_response_bridge, {Info, "./www"}),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    replace_route_handler(),
    nitrogen:run().

replace_route_handler() ->
    wf_handler:set_handler(named_route_handler, routes()).

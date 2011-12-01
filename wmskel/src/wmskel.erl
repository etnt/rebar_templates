%% @author author <author@example.com>
%% @copyright YYYY @author.

%% @doc {{appid}} startup code

-module({{appid}}).
-export([start/0, start_link/0, stop/0]).
-export([lm/0, to_binary/1, to_int/1]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

%% @spec start_link() -> {ok,Pid::pid()}
%% @doc Starts the app for inclusion in a supervisor tree
start_link() ->
    ensure_started(inets),
    ensure_started(crypto),
    ensure_started(mochiweb),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    ensure_started(webmachine),
    {{appid}}_sup:start_link().

%% @spec start() -> ok
%% @doc Start the {{appid}} server.
start() ->
    ensure_started(inets),
    ensure_started(crypto),
    ensure_started(mochiweb),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    ensure_started(webmachine),
    application:start({{appid}}).

%% @spec stop() -> ok
%% @doc Stop the {{appid}} server.
stop() ->
    Res = application:stop({{appid}}),
    application:stop(webmachine),
    application:stop(mochiweb),
    application:stop(crypto),
    application:stop(inets),
    Res.



to_binary(I) when is_integer(I) -> to_binary(integer_to_list(I));
to_binary(L) when is_list(L)    -> list_to_binary(L);
to_binary(B) when is_binary(B)  -> B.


to_int(B) when is_binary(B)  -> list_to_integer(binary_to_list(B));
to_int(L) when is_list(L)    -> list_to_integer(L);
to_int(I) when is_integer(I) -> I.


lm() ->
    load_modified_modules().

load_modified_modules() ->
    [c:l(M) || M <- modified_modules()].

modified_modules() ->
  [M || {M, _} <-  code:all_loaded(), module_modified(M) =:= true].

module_modified(Module) ->
  case code:is_loaded(Module) of
    {file, preloaded} ->
      false;
    {file, Path} ->
      CompileOpts = erlang:get_module_info(Module, compile),
      CompileTime = proplists:get_value(time, CompileOpts),
      Src = proplists:get_value(source, CompileOpts),
      case lists:last(Src) of
        $. ->
          false;  % compiled from abstract forms, no file
        _ ->
          module_modified(Path, CompileTime, Src)
      end;
    _ ->
      false
  end.

module_modified(Path, PrevCompileTime, PrevSrc) ->
  case find_module_file(Path) of
    non_existing ->
      removed;
    ModPath ->
      case beam_lib:chunks(ModPath, ["CInf"]) of
        {ok, {_, [{_, CB}]}} ->
	      CompileOpts =  binary_to_term(CB),
	      CompileTime = proplists:get_value(time, CompileOpts),
	      Src = proplists:get_value(source, CompileOpts),
	      not ((CompileTime == PrevCompileTime) and (Src == PrevSrc));
	  _ ->
	      false
      end
  end.

find_module_file(Path) ->
  case file:read_file_info(Path) of
    {ok, _} ->
      Path;
    _ ->
        %% maybe the path was changed?
        code:where_is_file(filename:basename(Path))
  end.

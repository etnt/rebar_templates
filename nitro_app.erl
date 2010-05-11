%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the {{appid}} application.

-module({{appid}}_app).
-behaviour(application).

-export([start/2, stop/1]).

-include_lib("nitrogen/include/wf.hrl").

start(_, _) ->
    %% Uncomment below iff using eopenid!
    %%eopenid:start(),
    Res = {{appid}}_sup:start_link(),
    {ok,_Pid} = {{appid}}_inets:start_link(), % ends up under the inets supervisors
    Res.

stop(_) ->
    %% Uncomment below iff using eopenid!
    %%eopenid:stop(),
    ok.




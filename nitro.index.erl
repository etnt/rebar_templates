%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

-module(index).
-include_lib("nitrogen/include/wf.hrl").
-export([main/0, title/0, layout/0]).

main() ->
    #template { file="./templates/grid.html" }.

title() ->
    "{{appid}}".

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body={{appid}}_common:header(home) },
              #grid_clear {},

              #grid_6 { alpha=true, body={{appid}}_common:left() },
              #grid_6 { omega=true, body={{appid}}_common:right() },
              #grid_clear {},
              
              #grid_12 { body={{appid}}_common:footer() }
             ]}.



%%% @author {{name}} <{{email}}>
%%% @copyright (C) 2010, {{name}}

-module({{appid}}_web_logout).

-export([main/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
    wf:user(undefined),
    wf:session(authenticated, false),
    wf:redirect("/").


	

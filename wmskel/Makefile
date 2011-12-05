ERL ?= erl
APP := {{appid}}

.PHONY: deps

all: deps
	@./rebar compile

deps:
	@./rebar get-deps

clean:
	@./rebar clean

distclean: clean
	@./rebar delete-deps

test: local_clean
	@./rebar eunit skip_app=mochiweb,webmachine

ct: all
	@./rebar -C rebar.config.test ct app={{appid}}

ctv: all
	@./rebar -C rebar.config.test ct app={{appid}} verbose=1

local_clean:
	@rm -f ./ebin/* .eunit/*

xref: all
	@./rebar xref skip_app=mochiweb,webmachine

docs:
	@erl -noshell -run edoc_run application '$(APP)' '"."' '[]'

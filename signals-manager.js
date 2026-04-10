#!/usr/bin/env node

import childProcess from "node:child_process";
import os from "node:os";

process.title = "signals-manager";

var proc,
    restart = false;

const IGNORED_SIGNALS = new Set( [ "SIGKILL", "SIGSTOP" ] );

for ( const signal in os.constants.signals ) {
    if ( IGNORED_SIGNALS.has( signal ) ) continue;

    process.on( signal, onSignal );
}

while ( true ) {
    const status = await start();

    if ( restart ) {
        restart = false;
    }
    else {
        process.exit( status.code );
    }
}

async function start () {
    proc = childProcess.spawn( process.argv[ 2 ], process.argv.slice( 3 ), {
        "cwd": process.cwd(),
        "detached": true,
        "stdio": "inherit",
    } );

    return new Promise( resolve =>
        proc.once( "close", ( code, signal ) => {
            proc = null;

            resolve( { code, signal } );
        } ) );
}

function onSignal ( signal ) {
    if ( signal === "SIGHUP" ) {
        restart = true;
    }
    else {
        restart = false;
    }

    kill( signal );
}

function kill ( signal ) {
    proc?.kill( signal );
}

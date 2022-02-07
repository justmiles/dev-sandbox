#!/bin/bash

docker run --rm -d --name dev-sandbox -v /home/justmiles/workspaces:/home/sandbox/workspaces -p 8081:8080 justmiles/dev-sandbox

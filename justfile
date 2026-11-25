image := "registry.chuckhires.net/agent-harness:latest"

build:
    docker build . -t {{image}}

push: build
    docker push {{image}}

run:
    docker run --rm -d --name agent-harness -v $PWD:/home/sandbox/workspaces -p 8080:8080 {{image}}

run-shell:
    docker run --rm -it --name agent-harness -v $PWD:/home/sandbox/workspaces --entrypoint bash {{image}}

generate-icons source output_dir="./media":
    ./scripts/generate-icons.sh {{source}} {{output_dir}}

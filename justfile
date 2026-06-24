image := "justmiles/dev-sandbox:slim"

build:
    docker build . -t {{image}}

push: build
    docker push justmiles/dev-sandbox

run:
    docker run --rm -d --name dev-sandbox -v $PWD:/home/sandbox/workspaces -p 8080:8080 {{image}}

run-shell:
    docker run --rm -it --name dev-sandbox -v $PWD:/home/sandbox/workspaces --entrypoint zsh {{image}}

generate-icons source output_dir="./media":
    ./scripts/generate-icons.sh {{source}} {{output_dir}}

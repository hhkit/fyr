FROM ubuntu
RUN apt update
RUN apt install -y texlive-full curl latexmk
RUN apt install -y python3-pip python3-pygments
RUN apt install -y pdf2svg git
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
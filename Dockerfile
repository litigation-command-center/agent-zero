# Use the pre-built base image for A0
FROM agent0ai/agent-zero-base:latest

# Set BRANCH to "local" if not provided
ARG BRANCH=local
ENV BRANCH=$BRANCH

# Copy filesystem files to root
COPY ./docker/run/fs/ /
# Copy current development files to git, they will only be used in "local" branch
COPY ./ /git/agent-zero

# pre installation steps
RUN bash /ins/pre_install.sh $BRANCH

# install A0
RUN bash /ins/install_A0.sh $BRANCH

# install additional software
RUN bash /ins/install_additional.sh $BRANCH

# cleanup repo and install A0 without caching, this speeds up builds
ARG CACHE_DATE=none
RUN echo "cache buster $CACHE_DATE" && bash /ins/install_A02.sh $BRANCH

# post installation steps
RUN bash /ins/post_install.sh $BRANCH

# Update the port in the run script to 8080 for Cloud Run
RUN sed -i 's/--port=80/--port=8080/g' /exe/run_A0.sh

# Make scripts executable
RUN chmod +x /exe/initialize.sh /exe/run_A0.sh /exe/run_searxng.sh /exe/run_tunnel_api.sh

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Start the application
CMD ["/exe/run_A0.sh"]

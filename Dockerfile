FROM quay.io/keboola/docker-base-r-packages:3.3.2-a

WORKDIR /home

# Initialize the transformation runner
COPY . /home/

# Install some commonly used R packages and the R application
RUN Rscript ./init.R

# Install the r-transformation package which is in the local directory
RUN R CMD build .
RUN R CMD INSTALL keboola.r.transformation_*

# Run the application
ENTRYPOINT Rscript ./main.R /data/

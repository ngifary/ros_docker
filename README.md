# ros_docker

Script to run docker image for BBR2 System in jetson.
* Adjust Dockerfile PUID and PGID to match host ID to have the correct permission inside container
* Adjust ros_docker.sh to change the host mounted directory

* For the birdrecorder ROS Isaac docker container need to adjust permissions and choose one of the following:
*     `chmod +x scripts/workspace-entrypoint.sh`
*     `chmod 775 scripts/workspace-entrypoint.sh`
*     `chmod 777 scripts/workspace-entrypoint.sh`

* Change ids (output from `id`)
* Adjust path to ros workspace directory
* Add volume bindings to project in ros_docker.sh  

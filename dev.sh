NAME=vpn_bounce
DOCKER_IMAGE=quay.io/txyliu/$NAME
echo image: $DOCKER_IMAGE
echo ""

HERE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case $1 in
    --build|-b)
        # change the url in python if not txyliu
        # build the docker container locally *with the cog db* (see above)
        docker build -t $DOCKER_IMAGE .
        # docker build --build-arg="CONDA_ENV=${NAME}" -t $DOCKER_IMAGE .
    ;;
    --push|-p)
        # login and push image to quay.io, remember to change the python constants in src/
        # sudo docker login quay.io
	    sudo docker push $DOCKER_IMAGE:latest
    ;;
    --sif)
        # test build singularity
        singularity build $NAME.sif docker-daemon://$DOCKER_IMAGE:latest
    ;;
    --key)
        cd scratch
        rm ./bounce_client*
    	ssh-keygen -f ./bounce_client -N '' -a 128 -t ed25519
    ;;
    --run|-r)
        # test run docker image
            # --mount type=bind,source="$HERE/scratch/res",target="/ref"\
            # --mount type=bind,source="$HERE/scratch/res/.ncbi",target="/.ncbi" \
            # --mount type=bind,source="$HERE/test",target="/ws" \
            # -e XDG_CACHE_HOME="/ws"\
            # -u $(id -u):$(id -g) \

            # --mount type=bind,source="$HERE/scratch/sshd",target="/var/run/sshd" \
            # --device /dev/vhost-net \
        shift
        docker run -it --rm \
            -p 2222:22 \
            --cap-add NET_ADMIN \
            --mount type=bind,source="$HERE/ws",target="/ws" \
            --workdir="/ws" \
            --name $NAME \
            --hostname $NAME \
            $DOCKER_IMAGE \
            $@
    ;;
    -t)
        ssh btest
    ;;
    *)
        echo "bad option"
        echo $1
    ;;
esac

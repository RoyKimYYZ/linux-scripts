az iot dps enrollment create --attestation-type symmetrickey --dps-name rk-iothub-dps --resource-group IOT --enrollment-id rk-iothub-device --device-id rk-iothub-device --query '{registrationID:registrationId,primaryKey:attestation.symmetricKey.primaryKey}'


export IOTHUB_DEVICE_SECURITY_TYPE="DPS"
export IOTHUB_DEVICE_DPS_ID_SCOPE="0ne00C7193D"
export IOTHUB_DEVICE_DPS_DEVICE_ID="rk-iothub-device" #: the value my-pnp-device."
export IOTHUB_DEVICE_DPS_DEVICE_KEY="yiZgmoFL5sstlmwKblHlt/LeBSBelLrNmpAb+DEJ3HA/vpZTA3uPRmMnu2gif7JJJtzhH61/dojaLkfWufuZ/g==" # the enrollment primary key you made a note of previously.
export IOTHUB_DEVICE_DPS_ENDPOINT="global.azure-devices-provisioning.net"
export IOTHUB_CONNECTION_STRING="HostName=rk-iothub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=akzrt4Au0eizKgngfmiOOTvHxTVxEm0DmAIoTH3TYys="
export IOTHUB_DEVICE_ID="rk-iothub-device"

export IOTHUB_DEVICE_SECURITY_TYPE="DPS"
export IOTHUB_DEVICE_DPS_ID_SCOPE="0ne00C7193D"
export IOTHUB_DEVICE_DPS_DEVICE_ID="rk-iothub-device" #: the value my-pnp-device."
export IOTHUB_DEVICE_DPS_DEVICE_KEY="yiZgmoFL5sstlmwKblHlt/LeBSBelLrNmpAb+DEJ3HA/vpZTA3uPRmMnu2gif7JJJtzhH61/dojaLkfWufuZ/g==" # the enrollment primary key you made a note of previously.
export IOTHUB_DEVICE_DPS_ENDPOINT="global.azure-devices-provisioning.net"
export IOTHUB_CONNECTION_STRING="HostName=rk-iothub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=akzrt4Au0eizKgngfmiOOTvHxTVxEm0DmAIoTH3TYys="
export IOTHUB_DEVICE_ID="rk-iothub-device"


# https://learn.microsoft.com/en-us/azure/iot/tutorial-connect-device?pivots=programming-language-ansi-c

sudo apt-get update
sudo apt-get install -y git cmake build-essential curl libcurl4-openssl-dev libssl-dev uuid-dev

sudo apt  install cmake  # version 3.16.3-1ubuntu1.20.04.1

cmake --version
gcc --version

git clone https://github.com/Azure/azure-iot-sdk-c.git
cd azure-iot-sdk-c
git submodule update --init

mkdir cmake
cd cmake

sudo apt-get install libssl-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install uuid-dev
cmake -Duse_prov_client=ON -Dhsm_type_symm_key=ON -Drun_e2e_tests=OFF ..
cmake --build .

cd iothub_client/samples/pnp/pnp_simple_thermostat/
./pnp_simple_thermostat
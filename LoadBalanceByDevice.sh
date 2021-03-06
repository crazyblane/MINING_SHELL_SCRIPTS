##############
#User Defines#
##############

# 1 for one instance per device, 0 for one instance for all devices, load balanced by the application
instancePerDevice=1

# Balance type if using one instance for all devices. I don't recommend it though... 1 bad pool seems to cause issues for all...
balanceType="--load-balance"

#miner="bfg"
miner="cg"

# Path to miner binary
cgminerPath="miners/cgminer/cgminer-current/./cgminer"
bfgminerPath="miners/bfgminer/bfgminer-current/./bfgminer"

if [ "$miner" == "bfg" ]; then  
# User modified device List for bfgminer
device[0]=/dev/ttyUSB0
device[1]=/dev/ttyUSB1
device[2]=/dev/ttyUSB2
device[3]=/dev/ttyUSB3
device[4]=/dev/ttyUSB4
device[5]=/dev/ttyUSB5
device[6]=/dev/ttyUSB6
device[7]=/dev/ttyUSB7
device[8]=/dev/ttyUSB8

# BFG miner specific settings
deviceSwitch="-S"
minerPath=$bfgminerPath
fi

if [ "$miner" == "cg" ]; then 

# User modified device list for cgminer
device[0]=1:4
device[1]=1:5
device[2]=1:6
device[3]=1:7
device[4]=1:8
device[5]=1:9
device[6]=1:11
device[7]=1:12
device[8]=1:13

# CG miner specific settings
deviceSwitch="--usb"
minerPath=$cgminerPath
fi

# Pool Array
poolName[0]="coinlab"
poolAddress[0]="http://pool.coinlab.com:8332"
poolCredentials[0]="ppspool_username:password"

poolName[1]="mtred"
poolAddress[1]="http://mine.mtred.com:8337"
poolCredentials[1]="username:password"

poolName[2]="ftybtc"
poolAddress[2]="http://pool.50btc.com:8332"
poolCredentials[2]="username:password"

poolName[3]="deepbit"
poolAddress[3]="http://pit.deepbit.net:8332"
poolCredentials[3]="username:password"

poolName[4]="emc"
poolAddress[4]="http://us3.eclipsemc.com:8337"
poolCredentials[4]="username:password"

poolName[5]="bitminter"
poolAddress[5]="http://mint.bitminter.com:8332"
poolCredentials[5]="username:password"

#poolName[6]="btcguild"
#poolAddress[6]="http://mine2.btcguild.com:8332"
#poolCredentials[6]="username:password"

poolName[6]="eligius"
poolAddress[6]="http://mining.eligius.st:8337"
poolCredentials[6]="btcaddress:x"

poolName[7]="slush"
poolAddress[7]="http://api.bitcoin.cz:8332"
poolCredentials[7]="username:password"

poolName[8]="ozcoin"
poolAddress[8]="http://stratum.ozco.in:3333"
poolCredentials[8]="username:password"

######################
## End user defines ##
######################

j=0
if [ $instancePerDevice -eq 1 ]; then # we are running one instance per device
        for (( i = 0; i < ${#device[@]} ; i++ )) do # for each device
        for (( k = 0; k < ${#poolName[@]} ; k++ )) do # enumerate all pools
            if [ $k -eq 0 ]; then # if this is the first pool in the current list, create the starting command
                mycommand="screen -dmS ${poolName[$j]} $minerPath" 
            fi
            mycommand+=" --url ${poolAddress[$j]} --userpass ${poolCredentials[$j]}" # add pool information using $j
            ((j++))
           
            if [ $j -ge ${#poolName[@]} ]; then # $j is set back to zero when we hit the end of the list.
                j=0
            fi
        done

        mycommand+=" $deviceSwitch ${device[$i]}"
        
        ((j++))
        if [ $j -ge ${#poolName[@]} ]; then # $j is set back to zero when we hit the end of the list.
            j=0
        fi
        #mycommand+=" --syslog"
        $mycommand

    done        
fi

if [ $instancePerDevice -eq 0 ]; then
    mycommand="screen -dmS combined $minerPath" 
    for (( k = 0; k < ${#poolName[@]} ; k++ )) do
        mycommand+=" --url ${poolAddress[$k]} --userpass ${poolCredentials[$k]}"
    done
    for (( i = 0; i < ${#device[@]} ; i++ )) do
        mycommand+=" $deviceSwitch ${device[$i]}"
    done
  #mycommand+=" --syslog "
	mycommand+=" $balanceType"
	$mycommand   
fi

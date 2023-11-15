namespace: aviator_flow



flow:
  name: aviator_flow
  inputs:
    - host
    - port:
        default: '22'
    - username
    - password
    - tomcat_home
    - backup_location
    - new_server_host # Optional, use if the original server is unavailable

  workflow:
    - stopTomcatService:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - port: '${port}'
            - username: '${username}'
            - password: '${password}'
            - command: "${tomcat_home + '/bin/shutdown.sh'}"
        navigate:
          - SUCCESS: backupData
          - FAILURE: FAILURE

    - backupData:
        do:
          io.cloudslang.base.files.copy:
            - source: "${tomcat_home + '/webapps/myapp'}" # Path to your app's data
            - destination: '${backup_location}'
        navigate:
          - SUCCESS: restoreDataOnNewServer
          - FAILURE: FAILURE

    - restoreDataOnNewServer:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${new_server_host}' # Use this if the original server is down
            - port: '${port}'
            - username: '${username}'
            - password: '${password}'
            - command: "${'cp -R ' + backup_location + ' ' + tomcat_home + '/webapps/myapp'}"
        navigate:
          - SUCCESS: startTomcatService
          - FAILURE: FAILURE

    - startTomcatService:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${new_server_host}'
            - port: '${port}'
            - username: '${username}'
            - password: '${password}'
            - command: "${tomcat_home + '/bin/startup.sh'}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE

  results:
    - SUCCESS
    - FAILURE

namespace: aviator_flow

imports:
  ssh: io.cloudslang.base.ssh
  files: io.cloudslang.base.files

flow:
  name: aviator_flow
  inputs:
    - host
    - port
    - username
    - password
    - tomcat_home
    - backup_location
    - new_server_host # if needed

  workflow:
    - stopTomcatService:
        do:
          ssh.ssh_command:
            - host
            - port
            - username
            - password
            - command: tomcat_home + '/bin/shutdown.sh'
        navigate:
          - SUCCESS: backupData
          - FAILURE: FAILURE

    - backupData:
        do:
          files.copy:
            - source: tomcat_home + '/webapps/myapp' # path to your app's data
            - destination: backup_location
        navigate:
          - SUCCESS: restoreDataOnNewServer
          - FAILURE: FAILURE

    - restoreDataOnNewServer:
        do:
          ssh.ssh_command:
            - host: new_server_host # Use new server if original is down
            - port
            - username
            - password
            - command: 'cp -R ' + backup_location + ' ' + tomcat_home + '/webapps/myapp'
        navigate:
          - SUCCESS: startTomcatService
          - FAILURE: FAILURE

    - startTomcatService:
        do:
          ssh.ssh_command:
            - host: new_server_host
            - port
            - username
            - password
            - command: tomcat_home + '/bin/startup.sh'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  results:
    - SUCCESS
    - FAILURE


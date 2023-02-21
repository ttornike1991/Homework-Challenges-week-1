# Homework-Challenges-week-1
Containerization
# 1. Run the Dockerfile CMD as an external script:

To run the CMD command in a Dockerfile as an external script, you can follow these steps:

- Create the external script: Create a script that contains the command you want to run in the container. For example, you might create a script called start.sh that contains the following command:

```
node app.js
```

This script would start a Node.js app in the container.

- Add the script to your Dockerfile: In your Dockerfile, add a line to copy the script to the container, and another line to run the script using the CMD command. For example:

 
```
COPY start.sh /usr/src/app/
CMD ["/bin/bash", "/usr/src/app/start.sh"]

```

This would copy the start.sh script to the /usr/src/app/ directory in the container and then run it as the CMD command.

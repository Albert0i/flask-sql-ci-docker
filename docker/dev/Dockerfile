ARG python_image_version
FROM python:$python_image_version

ARG app_name

RUN apk add --update --no-cache nodejs nodejs-npm postgresql-dev gcc python3-dev musl-dev libffi-dev curl nano elinks sqlite screen fortune

WORKDIR /root/
COPY $app_name $app_name

WORKDIR /root/$app_name
RUN pip install -r requirements/dev.txt
RUN pip install cowsay 
RUN npm install

EXPOSE 5000
EXPOSE 2992

CMD npx concurrently -n "WEBPACK,FLASK" -c "bgBlue.bold,bgMagenta.bold" "NODE_ENV=debug webpack-dev-server --port 2992 --hot --inline --host 0.0.0.0" "flask run --host=0.0.0.0"




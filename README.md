# node_framework
web app (admin) framework using node.js v0.10.x, angular.js v1.3.9, bootstrap v3.3.5, mysql and redis

Usage
=====
1. initialize

		> grunt init

2. add app

		> grunt add

3. add app component

		> grunt add:controllers
		> grunt add:models
		> grunt add:permissions
		> grunt add:restful
		> grunt add:app
		> grunt add:nav

4. add all app component

		> grunt add:controllers add:models add:permissions add:restful add:app add:nav

	is equal to

		> grunt add

5. export

		> grunt dist

6. generate mysql table create sql (in sql/)

		> grunt sql

7. update angular.js template html files by model definition

		> grunt tpl

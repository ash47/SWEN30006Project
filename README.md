~~ Version Control (Git) ~~

Please work on the 'dev' branch. Any features, which might break dev, should be developed on a separate branch:
$ git checkout -b feat/myfeature dev

and later merged back into dev:
$ git checkout dev
$ git merge --no-ff feat/myfeature

deleting the branch:
$ git branch -d feat/myfeature

For more detail, please see http://nvie.com/posts/a-successful-git-branching-model/


###Read This Ben###
 - I stuffed up migrations -- this was before I had any idea what the hell I was doing. Please delete your db/development.sqlite3 (or what ever you called it) if you get tons of errrors, and re migrate the db

###Creating admins###
 - This is somewhat temporay, to become an admin, just navigate to `/become_admin`, and to stop being an admin, just go to `/remove_admin`

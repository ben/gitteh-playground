path = require "path"
gitteh = require "gitteh"

module.exports = (app) ->
  class app.ApplicationController

    # GET /
    @index = (req, res) ->
      gitteh.openRepository path.join(__dirname, "../..", ".git"), (err, repo) =>
        head = repo.reference "HEAD", true, (err, ref) =>
          res.render 'index',
            view: 'index'
            err: err
            repo: repo
            ref: ref

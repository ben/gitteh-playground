path = require "path"
gitteh = require "gitteh"
async = require "async"

module.exports = (app) ->
  class app.ApplicationController

    app.aggregateTreeEntries = (arr, repo, tree, cb) ->
      entryHandler = (entry, next) ->
        ret =
          name: entry.name
          dir: entry.attributes == 16384
          children: []
        arr.push ret
        if ret.dir
          repo.tree entry.id, (err, t) => app.aggregateTreeEntries ret.children, repo, t,
            (err) -> next()
        else
          next()
      async.each tree.entries, entryHandler, (err) -> cb(arr) if cb

    app.recursiveAppendParent = (arr, repo, commitId, cb) ->
      repo.commit commitId, (err, commit) ->
        arr.push commit
        if commit.parents.length == 0
          cb(arr)
        else
          app.recursiveAppendParent arr, repo, commit.parents[0], cb


    # GET /
    @index = (req, res) ->
      repo = null
      head = null
      commit = null
      tree = null

      async.series {
        view: (cb) -> cb(null, 'index')
        repo: (cb) ->
          gitteh.openRepository path.join(__dirname, "../..", ".git"), (err, _repo) ->
            repo = _repo
            cb null, repo
        head: (cb) ->
          repo.reference "HEAD", true, (err, _ref) ->
            head = _ref
            cb null, head
        commit: (cb) ->
          repo.commit head.target, (err, _commit) ->
            commit = _commit
            cb null, commit
        tree: (cb) ->
          commit.tree (err, _tree) ->
            tree = _tree
            cb null, tree
        entries: (cb) ->
          app.aggregateTreeEntries [], repo, tree, (entries) ->
            cb null, entries
        commits: (cb) ->
          app.recursiveAppendParent [], repo, commit.id, (commits) ->
            cb null, commits
      }, (err, results) ->
        res.render 'index', results

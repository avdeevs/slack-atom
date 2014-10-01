# slack-atom package

This package brings Slack's feature of posting files to channels to Atom Editor.
To get it work:

* install package via _apm install slack-atom_ or Atom's UI
* add  slack's API key to your config.cson:
```coffeescript
  'slack-token': 'YOUR_API_KEY'
```

## Post a file (ctrl-alt-p)
Posts current file to channel

## Post a text snippet (ctrl-alt-o)
Posts selected text in current editor to channel

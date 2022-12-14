var flags = {
  user: JSON.parse(localStorage.getItem('user')) || null
  ,name_dict: JSON.parse(localStorage.getItem('name_dict')) || []
}

const app = Elm.Main.init({
  flags: flags
})

app.ports.outgoing.subscribe(( {tag, data}) => {
  switch (tag) {
    case 'saveUser':
      localStorage.setItem('lastLogin', Date.now());
      return localStorage.setItem('user', JSON.stringify(data))
    case 'clearUser':
      return localStorage.removeItem('user')
    case 'saveNameList':
      return localStorage.setItem('name_dict', JSON.stringify(data))
    default:
      return console.warn('Unrecognized Port', tag)
  }
}) 

setInterval(() => {
  app.ports.incoming.send({
    tag: 'time',
    data: Date.now()
  })
}, 10000)


// 一定期間ごとに認証情報を削除する
var period = 1000 * 60 * 60 * 24 * 7 // 1週間

setInterval(() => { 
  if (localStorage.getItem('lastLogin') !== null) {
    var lastLogin = parseInt(localStorage.getItem('lastLogin'))
    if (Date.now() - lastLogin > period) {
      localStorage.removeItem('user')
    }
  }
}, 1000 * 60); // 1分ごとに実行

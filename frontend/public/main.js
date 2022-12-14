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

var flags = {
  user: JSON.parse(localStorage.getItem('user')) || null
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
    default:
      return console.warn('Unrecognized Port', tag)
  }
}) 

setInterval(() => {
  app.ports.incoming.send({
    tag: 'time',
    data: Date.now()
  })
}, 1000)

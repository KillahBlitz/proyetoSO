import { createRouter, createWebHistory } from 'vue-router'
import Main from './components/Main.vue'
import Token from './components/Token.vue'

const routes = [
  {
    path: '/',
    name: 'Main',
    component: Main
  },
  {
    path: '/token',
    name: 'Token',
    component: Token
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
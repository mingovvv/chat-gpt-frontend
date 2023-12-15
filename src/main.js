import { createApp } from 'vue'
import App from './App.vue'
import UUID from 'vue3-uuid'
import Markdown from 'vue3-markdown-it'
import './index.css'

const elementApp = createApp(App);
elementApp.use(UUID);
elementApp.use(Markdown);
elementApp.mount('#app');
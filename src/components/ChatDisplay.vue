<template>
  <div class="flex flex-col flex-auto p-6 w-8/12">
    <div class="flex flex-col h-full max-h-screen rounded-2xl p-4 bg-gray-100 drop-shadow-lg">
      <div ref="displayRef" class="flex flex-col h-full mb-4 overflow-y-auto">
        <div class="flex flex-col">
          <div class="grid grid-cols-8">
            <!-- dialog bubbles -->
            <div v-for="(bubble, index) in bubbles" :key="index"
                 class="p-3 rounded-lg font-black"
                 :class="bubble.sender === HOST ? 'col-start-1 col-end-8' : 'col-start-9 col-end-2'"
            >
              <div class="flex" :class="bubble.sender === HOST ? 'flex-row' : 'flex-row-reverse'">
                <img v-if="bubble.sender === HOST"
                     class="hidden items-center justify-center h-10 w-10 rounded-full flex-shrink-0 bg-black md:flex"
                     alt="logo" src="../assets/logo.svg">
                <div :id="bubble.bubbleIndex"
                     ref="bubbleRefs"
                     class="leading-loose py-3 px-5 shadow-lg rounded-xl text-xs sm:text-sm sm:leading-loose lg:leading-loose break-all overflow-x-auto"
                     :class="[bubble.sender === HOST ? 'md:ml-5 bg-white' : 'bg-indigo-200',
                     isBouncing[bubble.bubbleIndex] ? 'animate-bounce' : ''
                     ]"
                >
                  <div v-if="bubble.sender === HOST && bubble.bubbleIndex !== 0 && bubble.text.length === 0" role="status">
                    <svg aria-hidden="true" class="inline w-4 h-4 text-gray-200 animate-spin dark:text-gray-600 fill-blue-600" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/>
                      <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/>
                    </svg>
                    <span class="sr-only">Loading...</span>
                  </div>
                  <Markdown :source="bubble.text.join('')" />
                </div>
                <div class=" mt-auto ml-2 mr-2">
                  <span class="text-xs text-center text-gray-500 hidden md:flex">{{ bubble.timestamp.toLocaleTimeString() }}</span>
                </div>
              </div>
            </div>
            <!-- dialog bubbles -->
          </div>
        </div>
      </div>
      <ChatInput ref="chatInputRef" @addBubble="addBubble" @clearBubbles="clearBubbles"  @clickStopButton="clickStopButton" :is-active="isActive"/>
    </div>
  </div>
</template>

<script setup>
import ChatInput from "@/components/ChatInput.vue";
import Markdown from "vue3-markdown-it";
import { GREETING_MSG, RE_GREETING_MSG, ERROR_MSG, USER, HOST } from "@/contant.js";
import { EventSourcePolyfill } from 'event-source-polyfill';
import { uuid } from "vue3-uuid";
import axios from "axios";
import { nextTick, ref, watch, defineEmits, defineExpose } from "vue";
import 'highlight.js/styles/dracula.css';

const emits = defineEmits(['totalBubbles']);

const displayRef = ref(null);
const bubbleRefs = ref([]);
const chatInputRef = ref(null);
const isActive = ref(false);
const isBouncing = ref([]);

let id = uuid.v4();
console.log(id);
let bubbleIndex = 0;
const bubbles = ref([{sender: HOST, text: [GREETING_MSG[Math.floor(Math.random() * GREETING_MSG.length)]], timestamp: new Date(), bubbleIndex: bubbleIndex++}]);

const addBubble = (message) => {
  bubbles.value.push({sender: USER, text: [message], timestamp: new Date(), bubbleIndex: bubbleIndex++});
  callReactiveMessage(message);
  emits('totalBubbles', bubbles);
}

let eventSource;
const callReactiveMessage = (message) => {
  bubbles.value.push({sender: HOST, text: [], timestamp: new Date(), bubbleIndex: bubbleIndex++});
  const lastBubble = bubbles.value[bubbles.value.length - 1];

  const url = `${process.env.VUE_APP_CHAT_GPT_BACKEND_URL}/chat?id=${id}&message=${message}`

  eventSource = new EventSourcePolyfill(url, {
    headers: {
      'Bypass-Tunnel-Reminder': 'pass',
      'User-Agent': 'non-standard browser'
    }
  });

  isActive.value = true;
  eventSource.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.isFinished === true) {
      lastBubble.text.push(data.message);
      isActive.value = false;
      displayRef.value.scrollTop = displayRef.value.scrollHeight;
      eventSource.close();
    } else {
      lastBubble.text.push(data.message);
      displayRef.value.scrollTop = displayRef.value.scrollHeight;
    }
  };

  eventSource.onerror = () => {
    displayRef.value.scrollTop = displayRef.value.scrollHeight;
    lastBubble.text.push(ERROR_MSG);
    eventSource.close();
    isActive.value = false;
  };

};

const clickStopButton = () => {
  eventSource.close();
  isActive.value = false;
}

const clearBubbles = () => {
  bubbles.value = [];
  id = uuid.v4();
  bubbleIndex = 0;
  bubbles.value.push({sender: HOST, text: [RE_GREETING_MSG[Math.floor(Math.random() * RE_GREETING_MSG.length)]], timestamp: new Date(), bubbleIndex: bubbleIndex++});
  emits('totalBubbles', bubbles);
  callDeleteMessageCache(id);
}

const callDeleteMessageCache = async (id) => {
  const url = `${process.env.VUE_APP_CHAT_GPT_BACKEND_URL}/messages?id=${id}`
  await axios.delete(url)
      .then(response => {
        console.log(`callDeleteMessageCache : ${response.data}`);
      })
      .catch(error => {
        console.log(`callDeleteMessageCache fail : ${error}`);
      });
}

const bounceBubble = (index) => {
  isBouncing.value[index] = true
  setTimeout(() => {
    isBouncing.value[index] = false
  }, 2500);
  bubbleRefs.value[index].scrollIntoView({ behavior: 'smooth' })
}

watch(() => bubbles.value.length, () => {
      nextTick(() => {
        displayRef.value.scrollTop = displayRef.value.scrollHeight;
      })
    }
);

defineExpose({
  bounceBubble
});

</script>

<style scoped>
:deep(.hljs) {
  border-radius: 0.5rem;
  overflow-x: auto;
}
</style>
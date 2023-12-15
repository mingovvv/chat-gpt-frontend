<template>
  <div class="container mx-auto">
    <div class="flex h-screen antialiased text-gray-800">
      <div class="flex flex-row h-full w-full">
        <ChatHistory :userBubbles="userBubbles" @searchQuestion="searchQuestion"/>
        <div class="flex flex-col flex-auto h-full p-6">
          <div class="flex flex-col flex-auto flex-shrink-0 rounded-2xl bg-gray-100 h-4/5 p-4 drop-shadow-lg">
            <div ref="windowContainer" class="flex flex-col h-full overflow-x-auto mb-4">
              <div class="flex flex-col h-full">
                <div class="grid grid-cols-8">
                  <!-- dialog bubbles -->
                  <div
                      class="p-4 leading-10 rounded-lg font-black"
                      v-for="(bubble, index) in bubbles" :key="index"
                      :class="bubble.sender === user ? 'col-start-9 col-end-2' : 'col-start-1 col-end-8'"
                  >
                    <div class="flex" :class="bubble.sender === user ? 'flex-row-reverse' : 'flex-row'"
                    >
                      <img v-if="bubble.sender === host"
                           class="flex items-center justify-center h-10 w-10 rounded-full flex-shrink-0 bg-black hidden md:flex"
                           alt="TLC logo" src="../assets/logo.svg">
                      <div v-bind:id="bubble.idx"
                           ref="idxs"
                           class="leading-loose py-3 px-5 shadow-lg rounded-xl text-xs sm:text-sm sm:leading-loose lg:text-base lg:leading-loose"
                           :class="bubble.sender === user ? 'mr-3 bg-indigo-200' : 'ml-3 bg-white'"
                      >
                        <Markdown :source="bubble.text" ></Markdown>
                      </div>
                      <div class=" mt-auto ml-2 mr-2">
                        <span class="text-xs text-center text-gray-500 hidden md:flex">{{ bubble.timestamp.toLocaleTimeString() }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <ChatInput ref="chatInput" @addMessage="addMessage" @clearBubbles="clearBubbles"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ChatInput from "@/components/ChatInput.vue";
import ChatHistory from "@/components/ChatHistory.vue";
import { ref, computed } from "vue";
import { uuid } from "vue3-uuid";
import { EventSourcePolyfill } from 'event-source-polyfill';
import axios from "axios";
import Markdown from 'vue3-markdown-it';
import 'highlight.js/styles/dracula.css';

export default {
  name: 'ChatWindow',
  components: {ChatInput, ChatHistory, Markdown},

  setup() {

    let idx = 0;
    let id = uuid.v4();
    const windowContainer = ref(null);
    const idxs = ref([]);
    const chatInput = ref(null);
    const host = 'TLC';
    const user = 'USER';
    const hostGreeting = '안녕하세요. 투라인코드입니다. 무엇을 도와드릴까요?';
    const hostErrorMsg = '현재 서버와의 통신이 원활하지 않습니다. 잠시 후 다시 시도해주세요.';

    const assistanceBubbles = ref([{sender: host, text: hostGreeting, timestamp: new Date(), idx: idx++}]);
    const userBubbles = ref([]);

    const addMessage = (message) => {
      addBubble(message);
    }

    const clearBubbles = () => {
      userBubbles.value = [];
      assistanceBubbles.value = [];
      assistanceBubbles.value.push({sender: host, text: hostGreeting, timestamp: new Date(), idx: idx++});
      deletedCache(id);
      id = uuid.v4();
    }

    const searchQuestion = (idx) => {
      console.log(idx);
      if (idxs.value[Number(idx)]) {
        idxs.value[Number(idx)].classList.add('animate-bounce');
        setTimeout(() => {
          idxs.value[Number(idx)].classList.remove('animate-bounce');
        }, 1500);
        idxs.value[Number(idx)].scrollIntoView();
      }
    }

    const bubbles = computed(() => {
      let result = [...assistanceBubbles.value, ...userBubbles.value];
      result.sort((a, b) => a.idx - b.idx);
      return result;
    });

    const addBubble = async (message) => {
      userBubbles.value.push({sender: user, text: message, timestamp: new Date(), idx: idx++});
      await reactiveCall(message);
    };

    const reactiveCall = (message) => {
      assistanceBubbles.value.push({sender: host, text: '', timestamp: new Date(), idx: idx++});
      const lastBubble = assistanceBubbles.value[assistanceBubbles.value.length - 1];

      const url = `${process.env.VUE_APP_CHAT_GPT_BACKEND_URL}/chat?id=${id}&message=${message}`
      const eventSource = new EventSourcePolyfill(url, {
        headers: {
          'Bypass-Tunnel-Reminder': 'pass',
          'User-Agent': 'non-standard browser'
        }
      });

      if (chatInput.value) {
        chatInput.value.activateStopButton(eventSource);
      }

      eventSource.onmessage = (event) => {
        const obj = JSON.parse(event.data);
        if (obj.isFinished === true) {
          eventSource.close();
          chatInput.value.activateSendButton();
        } else {
          lastBubble.text += obj.message;
          windowContainer.value.scrollTop = windowContainer.value.scrollHeight;
        }
      };

      eventSource.onerror = () => {
        chatInput.value.activateSendButton();
        lastBubble.text = hostErrorMsg;
        windowContainer.value.scrollTop = windowContainer.value.scrollHeight;
        eventSource.close();
      };

    };

    const deletedCache = async (id) => {
      const url = `${process.env.VUE_APP_CHAT_GPT_BACKEND_URL}/messages?id=${id}`
      await axios.delete(url)
          .then(response => {
            console.log(`cache deleted : ${response.data}`);
          })
          .catch(error => {
            console.log(`cache deleted fail : ${error}`);
          });
    }

    return {
      bubbles,
      userBubbles,
      addBubble,
      addMessage,
      searchQuestion,
      windowContainer,
      clearBubbles,
      chatInput,
      user, host, idxs
    };

  }

}
</script>
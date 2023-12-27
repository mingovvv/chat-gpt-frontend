<template>
  <div
      class="flex flex-row items-center max-h-56 rounded-xl bg-white w-full p-2 drop-shadow-lg border-2 border-indigo-200">
    <div>
      <!-- new topic button -->
      <button @click="clearBubbles"
              class="hidden sm:flex items-center h-12 rounded-xl text-white px-5 bg-gradient-to-r from-sky-400 to-blue-500 hover:from-sky-500 hover:to-blue-600"
      >
        <span class="hidden lg:flex mr-2">New Topic</span>
        <span>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 01-.825-.242m9.345-8.334a2.126 2.126 0 00-.476-.095 48.64 48.64 0 00-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0011.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
          </svg>
        </span>
      </button>
    </div>
    <div class="flex-grow">
      <div class="px-2">
        <!-- textarea -->
        <form @submit.prevent="addBubble">
          <textarea
              rows="1"
              ref="textareaRef"
              v-model="inputText"
              @keydown.enter.exact.prevent="addBubble"
              class="flex max-h-52 overflow-y-auto w-full focus:outline-none rounded-lg p-2 text-xs sm:text-sm lg:text-base"
              placeholder="무엇이든 물어보세요..! 😃"
          />
        </form>
      </div>
    </div>
    <div>
      <!-- send button -->
      <button
          ref="sendButtonRef"
          v-if=!isActive
          @click="addBubble"
          class="flex lg:w-24 items-center justify-center h-12 rounded-xl text-white px-5 bg-gradient-to-r from-sky-400 to-blue-500 hover:from-sky-500 hover:to-blue-600"
      >
        <span class="hidden mr-2 lg:flex">Send</span>
        <span>
          <svg class="w-4 h-4 transform rotate-45 -mt-px" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" ></path>
          </svg>
        </span>
      </button>
      <!-- stop button -->
      <button
          ref="stopButtonRef"
          v-if=isActive
          @click="$emit('clickStopButton')"
          class="flex lg:w-24 items-center justify-center h-12 rounded-xl text-white px-5 bg-gradient-to-r from-gray-500 to-black hover:from-gray-600 hover:to-gray-900"
      >
        <span class="hidden mr-2 lg:flex">Stop</span>
        <span>
          <svg class="w-4 h-4" fill="none" stroke-width="1.5" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.75 9.75l4.5 4.5m0-4.5l-4.5 4.5M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        </span>
      </button>
    </div>
  </div>
</template>

<script setup>

import { ref, watch, nextTick } from "vue";

const emits = defineEmits(['addBubble', 'clearBubbles', 'clickStopButton']);

const props = defineProps({
  isActive: Boolean
});

const textareaRef = ref(null);
const inputText = ref('');
const sendButtonRef = ref(null);
const stopButtonRef = ref(null);

const addBubble = (event) => {
  if (inputText.value.trim() !== '' && !props.isActive && !event.shiftKey) {
    emits("addBubble", inputText.value);
    inputText.value = ''
  } else if (event.shiftKey) {
    inputText.value = inputText.value += '\n';
  }
}

const clearBubbles = () => {
  emits('clearBubbles');
  inputText.value = ''
}

watch(inputText, () => {
  nextTick(() => {
    textareaRef.value.style.height = '1.5rem';
    textareaRef.value.style.height = `${textareaRef.value.scrollHeight}px`;
  })
})

</script>
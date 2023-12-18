<template>
  <div class="hidden md:flex flex-col flex-auto p-6 w-4/12">
    <div class="flex flex-col min-h-0 max-h-screen rounded-2xl p-4 bg-gray-100 drop-shadow-lg">
      <div class="flex flex-row justify-between border-b-2 border-b-blue-500">
        <span class="mb-5 font-bold">Dialog History</span>
        <span class="flex justify-center bg-blue-500 text-white h-6 w-6 rounded-full">
          {{ userBubbles.length }}
        </span>
      </div>
      <div ref="historyRef" class="flex flex-col space-y-4 mt-4 rounded-lg overflow-y-auto">
        <div v-if="userBubbles.length === 0" class="text-xs lg:text-sm text-center">
          ✏ 첫번째 대화를 시작하세요 💬
        </div>
        <button
            v-for="bubble in userBubbles" :key="bubble.bubbleIndex"
            @click="clickHistoryCard(bubble.bubbleIndex)"
            :title="bubble.text"
            class="flex flex-row items-center justify-between rounded-xl h-12 p-2 border-2 border-l-blue-500 hover:bg-white hover:border-blue-500
">
          <div class="text-xs ml-1 font-bold truncate">{{ bubble.text.toString() }}</div>
          <span class="text-xs mr-1 flex-shrink-0">{{ formatDateTime(bubble.timestamp) }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref, nextTick, watch} from "vue";

const props = defineProps({
  userBubbles: Array
});

const emits = defineEmits(['clickedIndex']);

const historyRef = ref(null);

const formatDateTime = (timestamp) => {
  const date = new Date(timestamp);
  return date.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
};

const clickHistoryCard = (bubbleIndex) => {
  emits('clickedIndex', bubbleIndex);
}

watch(() => props.userBubbles, () => {
      nextTick(() => {
        historyRef.value.scrollTop = historyRef.value.scrollHeight;
      })
    }
);
</script>
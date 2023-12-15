<template>
  <div ref="windowContainer" class="hidden flex-col h-3/5 mt-6 p-5 w-1/4 md:flex flex-shrink-0 rounded-2xl bg-white drop-shadow-lg overflow-y-auto">
    <div class="flex flex-col mt-8">
      <div class="flex flex-row items-center justify-between">
        <span class="font-bold">Dialog History</span>
        <span class="flex justify-center bg-blue-500 text-white h-6 w-6 rounded-full">
          {{ userBubbles.length }}
        </span>
      </div>
      <div class="flex flex-col space-y-4 mt-4 overflow-y-auto rounded-lg">
        <button
            @click="searchQuestion"
            v-bind:id="bubble.idx"
            v-for="bubble in userBubbles" :key="bubble.id"
            :title="bubble.text"
            class="flex flex-row items-center justify-between rounded-2xl h-12 p-2 border-4 border-l-blue-500 hover:bg-gray-100">
          <div class="text-xs ml-1 font-bold truncate">{{ bubble.text }}</div>
          <span class="text-xs mr-1 flex-shrink-0">{{ formatTime(bubble.timestamp) }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, nextTick, watchEffect } from 'vue';

export default {
  emits: ['selectedIdx'],
  props: {
    userBubbles: {
      type: Array,
      required: true,
    }
  },
  setup(props, {emit}) {

    const windowContainer = ref(null);

    const searchQuestion = (event) => {
      emit("searchQuestion", event.currentTarget.id);
    };

    const formatTime = (timestamp) => {
      const date = new Date(timestamp);
      return date.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
    };

    watchEffect(() => {
      props.userBubbles.length;
      nextTick(() => {
        windowContainer.value.scrollTop = windowContainer.value.scrollHeight;
      });
    });

    return {
      windowContainer,
      formatTime,
      searchQuestion
    };

  }
};
</script>
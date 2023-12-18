<template>
  <div class="container mx-auto">
    <div class="flex text-gray-800">
      <div class="flex flex-row h-screen w-full">
        <ChatHistory @clickedIndex="clickedIndex" :userBubbles="userBubbles"/>
        <ChatDisplay ref="displayRef" @totalBubbles="totalBubbles"/>
      </div>
    </div>
  </div>
</template>

<script setup>
import ChatHistory from "@/components/ChatHistory.vue";
import ChatDisplay from "@/components/ChatDisplay.vue";
import { USER } from "@/contant.js";
import { ref } from 'vue';

const displayRef = ref(null);
const userBubbles = ref([]);

const totalBubbles = (updateBubbles) => {
  userBubbles.value = updateBubbles.value.filter(b => b.sender === USER)
}

const clickedIndex = (index) => {
  displayRef.value.bounceBubble(index);
}
</script>
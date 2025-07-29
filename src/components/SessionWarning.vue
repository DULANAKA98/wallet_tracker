<template>
  <div v-if="showWarning" class="fixed top-4 right-4 z-50">
    <div
      class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded-lg shadow-lg max-w-md"
    >
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
              clip-rule="evenodd"
            ></path>
          </svg>
          <div>
            <p class="font-medium">Session Expiring Soon</p>
            <p class="text-sm">
              Your session will expire in {{ timeLeft }} seconds
            </p>
          </div>
        </div>
        <button
          @click="extendSession"
          class="ml-4 bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1 rounded text-sm font-medium transition-colors"
        >
          Stay Logged In
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from "vue";

export default {
  name: "SessionWarning",
  props: {
    lastActivity: {
      type: Number,
      required: true,
    },
    sessionDuration: {
      type: Number,
      default: 30 * 60 * 1000, // 30 minutes
    },
    warningTime: {
      type: Number,
      default: 5 * 60 * 1000, // 5 minutes before expiry
    },
  },
  emits: ["extend-session"],
  setup(props, { emit }) {
    const currentTime = ref(Date.now());
    const timeInterval = ref(null);

    const timeUntilExpiry = computed(() => {
      const timeSinceLastActivity = currentTime.value - props.lastActivity;
      return Math.max(0, props.sessionDuration - timeSinceLastActivity);
    });

    const showWarning = computed(() => {
      return (
        timeUntilExpiry.value <= props.warningTime && timeUntilExpiry.value > 0
      );
    });

    const timeLeft = computed(() => {
      return Math.ceil(timeUntilExpiry.value / 1000);
    });

    const extendSession = () => {
      emit("extend-session");
    };

    onMounted(() => {
      // Update current time every second
      timeInterval.value = setInterval(() => {
        currentTime.value = Date.now();
      }, 1000);
    });

    onUnmounted(() => {
      if (timeInterval.value) {
        clearInterval(timeInterval.value);
      }
    });

    return {
      showWarning,
      timeLeft,
      extendSession,
    };
  },
};
</script>

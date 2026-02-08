import { Image } from "expo-image";
import { useRouter } from "expo-router";
import LottieView from "lottie-react-native";
import { StyleSheet, TouchableOpacity } from "react-native";
import { useEffect } from "react";

import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { useAuth } from "@/contexts/AuthContext";

export default function WelcomeScreen() {
  const router = useRouter();
  const { user, loading } = useAuth();

  // Redirect if user is already authenticated
  useEffect(() => {
    if (!loading && user) {
      // User is authenticated, redirect to main app
      router.replace("/(tabs)");
    }
  }, [user, loading, router]);

  const handleSignUp = () => {
    router.push("/auth/signup");
  };

  const handleSignIn = () => {
    router.push("/auth/signin");
  };

  // Show loading while checking auth status
  if (loading) {
    return (
      <ThemedView style={styles.container}>
        <ThemedText style={styles.loadingText}>Loading...</ThemedText>
      </ThemedView>
    );
  }

  return (
    <ThemedView style={styles.container}>
      <ThemedView style={styles.header}>
        <Image
          source={require("@/assets/images/icon.png")}
          style={styles.logo}
        />
        <ThemedText type="title" style={styles.title}>
          Fantasy Betting
        </ThemedText>
        <ThemedText type="subtitle" style={styles.subtitle}>
          League Betting App
        </ThemedText>
        <ThemedText style={styles.description}>
          Join the ultimate fantasy football experience with real money betting
        </ThemedText>
      </ThemedView>

      <ThemedView style={styles.animationContainer}>
        <LottieView
          source={require("@/assets/lotti/football.json")}
          autoPlay
          loop
          style={styles.lottieAnimation}
        />
      </ThemedView>

      <ThemedView style={styles.buttonContainer}>
        <TouchableOpacity style={styles.primaryButton} onPress={handleSignUp}>
          <ThemedText style={styles.primaryButtonText}>
            Create Account
          </ThemedText>
        </TouchableOpacity>

        <TouchableOpacity style={styles.secondaryButton} onPress={handleSignIn}>
          <ThemedText style={styles.secondaryButtonText}>Sign In</ThemedText>
        </TouchableOpacity>
      </ThemedView>

      <ThemedView style={styles.footer}>
        <ThemedText style={styles.footerText}>
          By continuing, you agree to our Terms of Service and Privacy Policy
        </ThemedText>
      </ThemedView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0B1426",
    paddingHorizontal: 24,
    paddingTop: 60,
  },
  header: {
    alignItems: "center",
    marginBottom: 60,
    marginTop: 40,
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    color: "#FFFFFF",
    textAlign: "center",
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 20,
    color: "#FFD700",
    textAlign: "center",
    marginBottom: 16,
  },
  description: {
    fontSize: 16,
    color: "#B0B3B8",
    textAlign: "center",
    lineHeight: 24,
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  animationContainer: {
    alignItems: "center",
    marginVertical: 20,
    marginBottom: 20,
  },
  lottieAnimation: {
    width: 200,
    height: 100,
  },
  buttonContainer: {
    gap: 16,
    marginBottom: 40,
  },
  primaryButton: {
    backgroundColor: "#FFD700",
    paddingVertical: 16,
    paddingHorizontal: 32,
    borderRadius: 12,
    alignItems: "center",
    shadowColor: "#FFD700",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  primaryButtonText: {
    color: "#0B1426",
    fontSize: 18,
    fontWeight: "bold",
  },
  secondaryButton: {
    backgroundColor: "transparent",
    paddingVertical: 16,
    paddingHorizontal: 32,
    borderRadius: 12,
    alignItems: "center",
    borderWidth: 2,
    borderColor: "#FFD700",
  },
  secondaryButtonText: {
    color: "#FFD700",
    fontSize: 18,
    fontWeight: "600",
  },
  footer: {
    alignItems: "center",
    paddingHorizontal: 20,
  },
  footerText: {
    fontSize: 12,
    color: "#6B7280",
    textAlign: "center",
    lineHeight: 18,
  },
  loadingText: {
    fontSize: 18,
    color: "#FFFFFF",
    textAlign: "center",
    marginTop: 100,
  },
});

import { useRouter } from "expo-router";
import React, { useState } from "react";
import {
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  TextInput,
  TouchableOpacity,
} from "react-native";

import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { supabase } from "@/constants/Supabase";

export default function SignInScreen() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });
  const [loading, setLoading] = useState(false);

  const handleInputChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const validateForm = () => {
    if (!formData.email.trim()) {
      Alert.alert("Error", "Please enter your email");
      return false;
    }
    if (!/\S+@\S+\.\S+/.test(formData.email)) {
      Alert.alert("Error", "Please enter a valid email address");
      return false;
    }
    if (!formData.password.trim()) {
      Alert.alert("Error", "Please enter your password");
      return false;
    }
    return true;
  };

  const handleSignIn = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      // Sign in with Supabase Auth
      const { data, error } = await supabase.auth.signInWithPassword({
        email: formData.email,
        password: formData.password,
      });

      if (error) {
        throw error;
      }

      if (data.user) {
        Alert.alert("Success", "Signed in successfully!", [
          { text: "OK", onPress: () => router.push("/(tabs)") },
        ]);
      }
    } catch (error: any) {
      console.error("Signin error:", error);
      Alert.alert(
        "Error",
        error.message || "Invalid email or password. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleSignUp = () => {
    router.push("/auth/signup");
  };

  const handleForgotPassword = () => {
    Alert.alert(
      "Forgot Password",
      "Password reset functionality will be implemented soon."
    );
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <ThemedView style={styles.header}>
          <ThemedText type="title" style={styles.title}>
            Welcome Back
          </ThemedText>
          <ThemedText style={styles.subtitle}>
            Sign in to your fantasy football account
          </ThemedText>
        </ThemedView>

        <ThemedView style={styles.form}>
          <ThemedView style={styles.inputGroup}>
            <ThemedText style={styles.label}>Email</ThemedText>
            <TextInput
              style={styles.input}
              value={formData.email}
              onChangeText={(value) => handleInputChange("email", value)}
              placeholder="Enter your email"
              placeholderTextColor="#6B7280"
              keyboardType="email-address"
              autoCapitalize="none"
            />
          </ThemedView>

          <ThemedView style={styles.inputGroup}>
            <ThemedText style={styles.label}>Password</ThemedText>
            <TextInput
              style={styles.input}
              value={formData.password}
              onChangeText={(value) => handleInputChange("password", value)}
              placeholder="Enter your password"
              placeholderTextColor="#6B7280"
              secureTextEntry
            />
          </ThemedView>

          <TouchableOpacity
            style={styles.forgotPassword}
            onPress={handleForgotPassword}
          >
            <ThemedText style={styles.forgotPasswordText}>
              Forgot Password?
            </ThemedText>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.signInButton, loading && styles.buttonDisabled]}
            onPress={handleSignIn}
            disabled={loading}
          >
            <ThemedText style={styles.signInButtonText}>
              {loading ? "Signing In..." : "Sign In"}
            </ThemedText>
          </TouchableOpacity>
        </ThemedView>

        <ThemedView style={styles.footer}>
          <ThemedText style={styles.footerText}>
            Don't have an account?{" "}
            <ThemedText style={styles.linkText} onPress={handleSignUp}>
              Sign Up
            </ThemedText>
          </ThemedText>
        </ThemedView>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0B1426",
  },
  scrollContainer: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 60,
  },
  header: {
    alignItems: "center",
    marginBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#FFFFFF",
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: "#B0B3B8",
    textAlign: "center",
  },
  form: {
    gap: 20,
    marginBottom: 30,
  },
  inputGroup: {
    gap: 8,
  },
  label: {
    fontSize: 16,
    color: "#FFFFFF",
    fontWeight: "600",
  },
  input: {
    backgroundColor: "#1F2937",
    borderWidth: 1,
    borderColor: "#374151",
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 16,
    fontSize: 16,
    color: "#FFFFFF",
  },
  forgotPassword: {
    alignSelf: "flex-end",
    marginTop: -10,
  },
  forgotPasswordText: {
    color: "#FFD700",
    fontSize: 14,
    fontWeight: "600",
  },
  signInButton: {
    backgroundColor: "#FFD700",
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: "center",
    marginTop: 10,
    shadowColor: "#FFD700",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  signInButtonText: {
    color: "#0B1426",
    fontSize: 18,
    fontWeight: "bold",
  },
  footer: {
    alignItems: "center",
    marginTop: 20,
  },
  footerText: {
    fontSize: 16,
    color: "#B0B3B8",
  },
  linkText: {
    color: "#FFD700",
    fontWeight: "600",
  },
});

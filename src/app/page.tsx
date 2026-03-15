import { redirect } from "next/navigation";

// Root route — hand off to the admin dashboard inside the (admin) group
export default function RootPage() {
  redirect("/dashboard");
}

import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Exaltemps Solidaire",
  description: "Atelier Harness Engineering",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}

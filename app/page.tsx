import { getItems } from "@/lib/data";

export default function Home() {
  const items = getItems();

  return (
    <main style={{ padding: "2rem", fontFamily: "sans-serif" }}>
      <h1>Exaltemps Solidaire</h1>
      <p>Nos actions en cours :</p>
      <ul>
        {items.map((item) => (
          <li key={item.id}>{item.label}</li>
        ))}
      </ul>
    </main>
  );
}

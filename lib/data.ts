export type Item = {
  id: string;
  label: string;
};

export function getItems(): Item[] {
  return [
    { id: "1", label: "Collecte alimentaire" },
    { id: "2", label: "Maraude hivernale" },
    { id: "3", label: "Atelier numérique" },
  ];
}

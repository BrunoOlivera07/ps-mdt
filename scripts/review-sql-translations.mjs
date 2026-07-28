import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const targets = ["qbx.sql", "qbcore.sql"];
const replacements = [
  ["Estar presente e ou participar do ato de cobrança dos pais", "Estar presente e/ou participar do ato da acusação principal"],
  ["Acessório para ", "Cumplicidade em "],
  ["Acessório de ", "Cumplicidade em "],
  ["Acessório no ", "Cumplicidade no "],
  ["oficial de paz", "agente da lei"],
  ["Oficial de Paz", "Agente da Lei"],
  ["O ato de contratar um funcionário público contra sua vontade", "O ato de manter um funcionário público contra sua vontade"],
  ["Posse de contravenção de ", "Posse simples de "],
  ["Crime de fabricação Posse de ", "Posse criminosa oriunda da fabricação de "],
  ["Crime de fabricação de posse de ", "Posse criminosa oriunda da fabricação de "],
  ["A posse de carne magra em pequena quantidade", "A posse de Lean em pequena quantidade"],
  ["Obstrução Contravenção à Justiça", "Obstrução da Justiça (Contravenção)"],
  ["Crime de obstrução à justiça", "Obstrução da Justiça (Crime Grave)"],
  ["<h2>Background</h2>", "<h2>Contexto</h2>"],
  ["<strong>NEVER</strong>", "<strong>NUNCA</strong>"],
  ["em it.</li>", "nele.</li>"],
  ["<strong>Misdemeanor</strong>", "<strong>Contravenção</strong>"],
  ["<strong>Felony</strong>", "<strong>Crime grave</strong>"],
  ["Contraven??o", "Contravenção"],
  ["A manobra de poço", "A manobra PIT"],
  ["Manobra de Pit", "Manobra PIT"],
  ["Jaywalking", "Travessia irregular"],
  ["ativo Tiro", "Atirador ativo"],
];

for (const target of targets) {
  const path = resolve(root, "sql", target);
  let sql = (await readFile(path, "utf8")).replaceAll("\\'", "''").replaceAll("Roubar''s Liqour", "Rob''s Liquor").replaceAll("Rob''s Liqour", "Rob''s Liquor");
  for (const [source, replacement] of replacements) sql = sql.replaceAll(source, replacement);
  sql = sql.replace(
    /<p><em>\s*"Juro solenemente:[\s\S]*?nas quais estou prestes a ingressar\./g,
    '<p><em>"Juro solenemente: apoiarei, protegerei e defenderei a Constituição e o Governo dos Estados Unidos e do Estado; prestarei estrita obediência aos meus superiores na Agência de Aplicação da Lei e observarei todas as ordens e regulamentos prescritos por eles para o governo e a administração da Patrulha; sempre me conduzirei com sobriedade, honra e honestidade; manterei atenção rigorosa, pontual e constante aos meus deveres; absterei-me de qualquer conduta ofensiva ou incompatível com um agente da lei; desempenharei minhas funções sem medo, com imparcialidade e a devida cortesia; e cumprirei bem e fielmente os deveres do cargo que agora assumo. Que Deus me ajude."</em></p>',
  );
  sql = sql.replace(
    /<p><strong>Condução de emergência \(sem perseguição\):<\/strong>[\s\S]*?<strong>Seguindo:<\/strong>[\s\S]*?parar\.<\/p>/g,
    '<p><strong>Condução de emergência (sem perseguição):</strong> Operação de um veículo de emergência, com luzes vermelhas e azuis e sirene acionadas, por um agente da lei em resposta a uma situação de risco à vida ou a um crime violento em andamento, observando a segurança de terceiros.</p><p><strong>Condução em perseguição:</strong> Tentativa de um agente da lei, operando um veículo de emergência com luzes e sirene acionadas, de abordar os ocupantes de outro veículo em movimento quando o condutor em fuga está ciente da tentativa e resiste à abordagem mantendo ou aumentando a velocidade, desobedecendo às leis de trânsito ou tentando escapar.</p><p>Os agentes devem manter distância segura do veículo suspeito durante a perseguição para permitir frenagens de emergência. A manobra PIT só pode ser realizada por supervisores ou agentes certificados, sem trânsito próximo e fora de áreas residenciais.</p><p><strong>Acompanhamento:</strong> Condução próxima a um veículo de interesse sem empregar meios de abordagem, como luzes, sirene ou outra ordem de parada.</p>',
  );
  await writeFile(path, sql, "utf8");
  console.log(`Reviewed sql/${target}`);
}

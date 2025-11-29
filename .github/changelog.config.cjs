module.exports = {
  releaseCount: 1,
  linkCompare: false,
  linkReferences: false,
  writerOpts: {
    mainTemplate: `{{#each commitGroups}}
### {{title}}
{{#each commits}}- {{header}}
{{/each}}
{{/each}}`,
    headerPartial: "",
    footerPartial: "",
  },
};

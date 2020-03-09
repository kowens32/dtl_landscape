export default (urlOrSlug, project) => {
  if (urlOrSlug) {
    const url = urlOrSlug.indexOf("crunchbase.com") > 0 ? urlOrSlug : `https://www.crunchbase.com/organization/${urlOrSlug}`;
    if (project.crunchbaseData === undefined){
      return project.crunchbase === url;
    }
    return project.crunchbase === url || project.crunchbaseData.parents.includes(url);
  }
}

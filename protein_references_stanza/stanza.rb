class ProteinReferencesStanza < TogoStanza::Stanza::Base
  property :references do |tax_id, gene_id|
    references = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX up:   <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?pmid ?title (GROUP_CONCAT(?author, ", ") AS ?authors) ?date ?name ?pages ?volume ?same
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:citation ?citation .
        ?citation skos:exactMatch ?pmid .
        FILTER    REGEX (STR(?pmid), "pubmed") .

        ?citation up:title   ?title ;
                  up:author  ?author ;
                  up:date    ?date ;
                  up:name    ?name ;
                  up:pages   ?pages ;
                  up:volume  ?volume ;
                  foaf:primaryTopicOf ?same .
      }
      GROUP BY ?pmid ?title ?date ?name ?pages ?volume ?same
      ORDER BY ?date
    SPARQL
  end
end

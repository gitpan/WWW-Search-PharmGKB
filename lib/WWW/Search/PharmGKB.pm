package WWW::Search::PharmGKB;
use strict;
use SOAP::Lite;
import SOAP::Data 'type';
use English;
use Carp;
use vars qw($VERSION);

$VERSION = 1.08;

#Usage: new WWW::Search::PharmGKB

sub new {
    my $class = shift;
    my $self = bless {
        proxy => 'http://www.pharmgkb.org/services/PharmGKBItem',
        uri => 'PharmGKBItem',
        readable => 1,
    },
    $class;
    return $self;
}


#Usage: $self->gene_search(<gene_name>);
#returns: a referenced hash. The keys are
#            'drugs', 'name', 'symbol', 'pathways', 'drugs', 'diseases', 'phenotypes',
#	    'alternate_names', 'alternate_symbols'
#Note: all the keys contain referenced arrays as values. in the pathway value,
#      the array has  key => value pairs 'pathway' => 'pharmGKB URL' as elements.
#      All other keys have referenced array of PharmGKB IDs.


sub gene_search {

    my $self = shift;
    my($gene) = @_;
    my $result_obj = {};
    my $pharm_ids = $self->_search($gene, 'Gene');
    if($pharm_ids) {

        foreach my $gene_id(@{$pharm_ids}) {
            my $local_hash = {};
            my $soap_service = SOAP::Lite
		-> readable ($self->{readable})
		-> uri($self->{uri})
		-> proxy($self->{proxy})
		-> searchGene ($gene_id);
	    my $search_result = $soap_service->result;
	    $local_hash->{'alternate_names'} = '';
	    $local_hash->{'drugs'} = '';
	    $local_hash->{'diseases'} = '';
	    $local_hash->{'phenotypes'} = '';
	    $local_hash->{'pathways'} = '';
	    $local_hash->{'alternate_symbols'} = '';
	    $local_hash->{'name'} = '';
	    $local_hash->{symbol} = '';

            my @pathways = ();
	    if($search_result->{'geneRelatedPathways'}) {
		my $pathway_result = $search_result->{'geneRelatedPathways'};

		for(my $i = 0; $i <scalar(@{$pathway_result}); $i+= 2) {
		    push(@pathways, {$pathway_result->[$i] => $pathway_result->[$i+1]});
		}
	    }
            $local_hash->{'pathways'} = \@pathways;
	    if($search_result->{geneName}) {
		$local_hash->{name} = $search_result->{geneName};
	    }
	    if($search_result->{geneSymbol}) {
		$local_hash->{symbol} = $search_result->{geneSymbol};
	    }
            if($search_result->{'geneAlternateNames'}) {
		$local_hash->{'alternate_names'} = $search_result->{'geneAlternateNames'};
	    }
	    if($search_result->{'geneRelatedDrugs'}) {
		$local_hash->{'drugs'} = $search_result->{'geneRelatedDrugs'};
	    }
	    if($search_result->{'geneRelatedDiseases'}) {
		$local_hash->{'diseases'} = $search_result->{'geneRelatedDiseases'};
	    }
	    if($search_result->{'geneAlternateSymbols'}) {
		$local_hash->{'alternate_symbols'} = $search_result->{'geneAlternateSymbols'};
	    }
	    if($search_result->{'geneRelatedPhenotypeDatasets'}) {
		$local_hash->{'phenotypes'} = $search_result->{'geneRelatedPhenotypeDatasets'};
	    }

            $result_obj->{$gene_id} = $local_hash;
        }
    }
    else {
        print "Gene $gene was not found in PharmGKB!\n";
    }
    return $result_obj;
}


#Usage: $self->disease_search(<disease_name>);
#returns: a referenced hash. The keys are
#            'drugs', 'names', 'pathways', 'drugs', 'genes', 'phenotypes'
#Note: all the keys contain referenced arrays as values. in the pathway value,
#      the array has  key => value pairs 'pathway' => 'pharmGKB URL' as elements.
#      All other keys have referenced array of PharmGKB IDs.

sub disease_search {

    my $self = shift;
    my($disease) = @_;
    my $result_obj = {};
    my $pharm_ids;
    if($disease) {
        $pharm_ids = $self->_search($disease, 'Disease');
    }
    else {
        print "\'$disease\' is weird. I can't search that\n";
        return 0;
    }

    if($pharm_ids) {

        foreach my $disease_id(@{$pharm_ids}) {
            my $local_hash = {};
            my $soap_service = SOAP::Lite
		-> readable (1)
		-> uri($self->{uri})
		-> proxy($self->{proxy})
		-> searchDisease ($disease_id);
	    
	    	
	    my $search_result = $soap_service->result;
	    $local_hash->{'names'} = '';
	    $local_hash->{'drugs'} = '';
	    $local_hash->{'genes'} = '';
	    $local_hash->{'phenotypes'} = '';
	    $local_hash->{'pathways'} = '';

	    my @pathways = ();
	    if($search_result->{'diseaseRelatedPathways'}) {
		my $pathway_result = $search_result->{'diseaseRelatedPathways'};

		for(my $i = 0; $i <scalar(@{$pathway_result}); $i+= 2) {
		    push(@pathways, {$pathway_result->[$i] => $pathway_result->[$i+1]});
		}
	    }
            $local_hash->{'pathways'} = \@pathways;
	    if($search_result->{'diseaseAlternateNames'}) {
		$local_hash->{'names'} = $search_result->{'diseaseAlternateNames'};
	    }
	    if($search_result->{'diseaseRelatedDrugs'}) {
		$local_hash->{'drugs'} = $search_result->{'diseaseRelatedDrugs'};
	    }
	    if($search_result->{'diseaseRelatedGenes'}) {
		$local_hash->{'genes'} = $search_result->{'diseaseRelatedGenes'};
	    }
	    if($search_result->{'diseaseRelatedPhenotypeDatasets'}) {
		$local_hash->{'phenotypes'} = $search_result->{'diseaseRelatedPhenotypeDatasets'};
	    }

            $result_obj->{$disease_id} = $local_hash;
        }
    }
    else {
        print "Disease $disease was not found in PharmGKB!\n";
    }
    return $result_obj;
}


#Usage: $self->drug_search(<drug_name>);
#returns: a referenced hash. The keys are
#            'diseases', 'generic_names', 'trade_names', 'pathways', 'genes',
#	    'phenotypes', 'category', 'classification'
#Note: all the keys contain referenced arrays as values. in the pathway value,
#      the array has  key => value pairs 'pathway' => 'pharmGKB URL' as elements.
#      All other keys have referenced array of PharmGKB IDs.

sub drug_search {
    my $self = shift;
    my($drug) = @_;
    my $result_obj = {};
    my $pharm_ids;
    if($drug) {
        $pharm_ids = $self->_search($drug, 'Drug');
    }
    else {
        print "\'$drug\' is weird. I can't search that\n";
        return 0;
    }
    if($pharm_ids) {
        foreach my $drug_id(@{$pharm_ids}) {
            my $local_hash = {};
            my $soap_service = SOAP::Lite
		-> readable (1)
		-> uri($self->{uri})
		-> proxy($self->{proxy})
		-> searchDrug ($drug_id);
		
	    my $search_result = $soap_service->result;
	    $local_hash->{'generic_names'} = '';
	    $local_hash->{'trade_names'} = '';
	    $local_hash->{'category'} = '';
	    $local_hash->{'classification'} = '';
	    $local_hash->{'genes'} = '';
	    $local_hash->{'diseases'} = '';
	    $local_hash->{'phenotypes'} = '';
	    $local_hash->{'pathways'} = '';
	    $local_hash->{'name'} = '';
            my @pathways = ();
	    if($search_result->{'drugRelatedPathways'}) {
		my $pathway_result = $search_result->{'drugRelatedPathways'};

		for(my $i = 0; $i < scalar(@{$pathway_result}); $i+= 2) {
		    push(@pathways, {$pathway_result->[$i] => $pathway_result->[$i+1]});
		}
	    }
            $local_hash->{'pathways'} = \@pathways;
	    if($search_result->{'drugName'}) {
		$local_hash->{'name'} = $search_result->{'drugName'};
	    }
	    if($search_result->{'drugGenericNames'}) {
		$local_hash->{'generic_names'} = $search_result->{'drugGenericNames'};
	    }
	    if($search_result->{'drugTradeNames'}) {
		$local_hash->{'trade_names'} = $search_result->{'drugTradeNames'};
	    }
	    if($search_result->{'drugCategory'}) {
		$local_hash->{'category'} = $search_result->{'drugCategory'};
	    }
	    if($search_result->{'drugVaClassifications'}){
		$local_hash->{'classification'} = $search_result->{'drugVaClassifications'};
	    }
	    if($search_result->{'drugRelatedGenes'}) {
		$local_hash->{'genes'} = $search_result->{'drugRelatedGenes'};
	    }
	    if($search_result->{'drugRelatedDiseases'}) {
		$local_hash->{'diseases'} = $search_result->{'drugRelatedDiseases'};
	    }
	    if($search_result->{'drugRelatedPhenotypeDatasets'}) {
		$local_hash->{'phenotypes'} = $search_result->{'drugRelatedPhenotypeDatasets'};
	    }

            $result_obj->{$drug_id} = $local_hash;
        }
    }
    else {
        print "Drug $drug was not found in PharmGKB!\n";
    }
    return $result_obj;
}


#Usage: $self->publication_search(<something>);
#Returns: A referenced hash


sub publication_search {

    my $self = shift;
    my($search_term) = @_;
    my $pharm_ids;
    my $result_obj = {};
    if($search_term) {
	$pharm_ids = $self->_search($search_term, 'Publication');
    }
    else {
	print "\'$search_term\' is weird. I can't search that\n";
	return 0;
    }
    if($pharm_ids) {
	foreach my $id(@{$pharm_ids}) {
	    my $local_hash = {};
	    my $soap_service = SOAP::Lite
		-> readable ($self->{readable})
		-> uri($self->{uri})
		-> proxy($self->{proxy})
		-> searchPublication ($id);

	    my $search_result = $soap_service->result;
	    $local_hash->{'grant_id'} = '';
	    $local_hash->{'journal'} = '';
	    $local_hash->{'title'} = '';
	    $local_hash->{'month'} = '';
	    $local_hash->{'abstract'} = '';
	    $local_hash->{'authors'} = '';
	    $local_hash->{'volume'} = '';
	    $local_hash->{'page'} = '';
	    $local_hash->{'cross_reference'} = '';
	    $local_hash->{'year'} = '';

	    if($search_result) {

		if($search_result->{publicationGrantIds}) {
		    $local_hash->{'grants_id'} = $search_result->{publicationGrantIds};
		}
		if($search_result->{publicationJournal}) {
		    $local_hash->{journal} = $search_result->{publicationJournal};
		}
		if($search_result->{publicationName}) {
		    $local_hash->{title} = $search_result->{publicationName};
		}
		if($search_result->{publicationMonth}) {
		    $local_hash->{month} = $search_result->{publicationMonth};
		}
		if($search_result->{publicationAbstract}) {
		    $local_hash->{'abstract'} = $search_result->{publicationAbstract};
		}
		if($search_result->{publicationAuthors}) {
		    $local_hash->{authors} = $search_result->{publicationAuthors};
		}
		if($search_result->{publicationVolume}) {
		    $local_hash->{volume} = $search_result->{publicationVolume};
		}
		if($search_result->{publicationPage}) {
		    $local_hash->{page} = $search_result->{publicationPage};
		}
		if($search_result->{publicationAnnotationCrossReference}) {
		    my $references = $search_result->{publicationAnnotationCrossReference};
		    my @references_array = ();
		    for(my $i=0; $i < scalar(@{$references});$i+=2) {

			push(@references_array, {$references->[$i] => $references->[$i+1]});

		    }
		    $local_hash->{'cross_reference'} = \@references_array;
		}
		if($search_result->{publicationYear}) {
		    $local_hash->{year} = $search_result->{publicationYear};
		}
	    }
	    $result_obj->{$id} = $local_hash;
	}
    }
    else {
	print "No results found for $search_term\n";

    }
    return $result_obj;
}


sub _search {
    my $self = shift;
    my($search_term, $key) = @_;
    my @pharm_id = ();

    my $soap_service = SOAP::Lite
        -> readable ($self->{readable})
	-> uri('SearchService')
	-> proxy('http://www.pharmgkb.org/services/SearchService')
        -> search ($search_term);
    my $search_result = $soap_service->result;  
    foreach my $search_obj(@{$search_result}) {

	if($search_obj->[1] =~ m/$key/ig) {
	    push(@pharm_id, $search_obj->[0]);

	}
    }
    return \@pharm_id;

}

1;


=head1 NAME

WWW::Search::PharmGKB - Search and retrieve information from the PharmGKB database

=head1 VERSION

Version 1.08

=cut

=head1 SYNOPSIS

    use WWW::Search::PharmGKB;
    use Data:Dumper;
    my $pharmgkb = WWW::Search::PharmGKB->new();
    my $search_result = $pharmgkb->gene_search('CYP2D6');
    print Dumper $search_result;

=head1 DESCRIPTION

    PharmGKB provides web services API to query their database. This module is an object oriented,
    more flexible wrapper for the SOAP service. You can search for genes, publications, drugs and
    diseases (more to come soon :) ). Note that the PharmGKB SOAP service is kinda slow and sometimes
    a bit annoying too, but you will get some good quality data and it's better to wait for the
    script to do the job than manual curation ;)

=head1 METHODS

=head2 Constructor

    my $pharmgkb = new WWW::Search::PharmGKB;

=head2 gene_search

    Usage: $self->gene_search('CYP2D6');

    This method is used to search for information about genes. the method takes in only one gene name
    at a time. It returns a referenced hash like this :
    'PA128' => {
                     'pathways' => [
                                     {
                                       'Anti-estrogen Pathway (Tamoxifen PK)' => '/search/pathway/antiestrogen/tamoxifen.jsp'
                                     },
                                     {
                                       'Celecoxib Pathway' => '/search/pathway/celecoxib/celecoxib.jsp'
                                     },
                                     {
                                       'Codeine and Morphine Pathway (PK)' => '/search/pathway/codeine-morphine/codeineMorphine-pk.jsp'
                                     },
                                     {
                                       'Statin Pathway (PK)' => '/search/pathway/statin/statin-pk.jsp'
                                     }
                                   ],
                     'symbol' => 'CYP2D6',
                     'drugs' => [
                                  'PA131887008',
                                  'PA151958637',
                                  'PA134687949',
                                  'PA448015',
                                  'PA448073',
                                  'PA448333',
                                ],
                     'alternate_names' => [
                                            'CPD6',
                                            'CYP2D',
                                            'P450-DB1',
                                            'P450C2D',
                                            'cytochrome P450, subfamily IID (debrisoquine, sparteine, etc., -metabolizing), polypeptide 6',
                                            'cytochrome P450, subfamily IID (debrisoquine, sparteine, etc., -metabolizing)-like 1',
                                            'debrisoquine 4-hydroxylase',
                                            'flavoprotein-linked monooxygenase',
                                            'microsomal monooxygenase',
                                            'xenobiotic monooxygenase'
                                          ],
                     'diseases' => [
                                     'PA443485',
                                     'PA443548',

                                   ],
                     'name' => 'cytochrome P450, family 2, subfamily D, polypeptide 6',
                     'phenotypes' => [
                                       'PA129411305',
                                       'PA133888873',
                                       'PA133888879',
                                       'PA133888980',
                                       'PA134736042',
                                       'PA134736059',
                                       'PA135349620',
                                       'PA160680259',
                                       'PA646603'
                                     ],
                     'alternate_symbols' => [
                                              'CPD6',
                                              'CYP2D',
                                              'CYP2D@',
                                              'CYP2DL1',
                                              'MGC120389',
                                              'MGC120390',
                                              'P450-DB1',
                                              'P450C2D'
                                            ]
                   }
        };

=head2 disease_search

    Usage: $sef->disease_search('AIDS');

    This method is used to search for information about diseases.
    It returns a referenced hash like this :
    $var = {
	  'PA446816' => {
                        'pathways' => [],
                        'drugs' => '',
                        'names' => [
                                     'AIDS Wasting Syndrome',
                                     'HIV Wasting Disease',
                                     'Slim Disease',
                                     'Wasting Disease, HIV',
                                     'Wasting Syndrome, AIDS',
                                     'Wasting Syndrome, HIV'
                                   ],
                        'genes' => '',
                        'phenotypes' => ''
                      },
          'PA446298' => {
                        'pathways' => [],
                        'drugs' => '',
                        'names' => [
                                     'AIDS, Murine',
                                     'AIDSs, Murine',
                                     'MAIDS',
                                     'Murine AIDS',
                                     'Murine AIDSs',
                                     'Murine Acquired Immune Deficiency Syndrome',
                                     'Murine Acquired Immuno Deficiency Syndrome',
                                     'Murine Acquired Immuno-Deficiency Syndrome'
                                   ],
                        'genes' => '',
                        'phenotypes' => ''
                      }
        };

=head2 drug_search

    Usage: $sef->drug_search('AIDS');

    This method is used to search for information about drugs.
    It returns a referenced hash like this :
    $var = {

	    'PA448508' => {
                        'pathways' => [],
                        'diseases' => '',
                        'genes' => '',
                        'name' => 'attapulgite',
                        'classification' => [
                                              'GA208'
                                            ],
                        'category' => '',
                        'phenotypes' => '',
                        'trade_names' => [
                                           'Diar-Aid',
                                           'Diarrest',
                                           'Diasorb',
                                           'Diatrol',
                                           'Donnagel',
                                           'Fowler\'s',
                                           'K-Pek',
                                           'Kaopectate',
                                           'Kaopectate Advanced Formula',
                                           'Kaopectate Maximum Strength',
                                           'Kaopek',
                                           'Parepectolin',
                                           'Rheaban'
                                         ],
                        'generic_names' => ''
                      },
          'PA448497' => {
                        'pathways' => [
                                        {
                                          'Celecoxib Pathway' => '/search/pathway/celecoxib/celecoxib.jsp'
                                        },
                                        {
                                          'Platelet Aggregation Pathway (PD)' => '/search/pathway/platelet/platelet-pd.jsp'
                                        }
                                      ],
                        'diseases' => [
                                        'PA443425',
                                        'PA443635',
                                        'PA447054',
                                        'PA446108',
                                        'PA443842',
                                        'PA445019',
                                        'PA153619833',
                                        'PA131285571'
                                      ],
                        'genes' => [
                                     'PA117',
                                     'PA130',
                                     'PA29938',
                                     'PA205',
                                     'PA378',
                                     'PA32868',
                                     'PA24346',
                                     'PA293',
                                     'PA37181'
                                   ],
                        'name' => 'aspirin',
                        'classification' => '',
                        'category' => '',
                        'phenotypes' => [
                                          'PA161845844'
                                        ],
                        'trade_names' => [
                                           '217',
                                           '217 Strong',
                                           '8-Hour Bayer',
                                           'Acetaminophen, Aspirin And Caffeine',
                                           'Acetaminophen, Aspirin, And Codeine Phosphate',
                                           'Acuprin 81',
                                           'Aggrenox',
                                           'Anacin',
                                           'Anacin Caplets',
                                           'Anacin Extra Strength',
                                           'Anacin Maximum Strength',
                                           'Anacin Tablets',
                                           'Antidol',
                                           'Apo-ASA',
                                           'Apo-ASEN'
                                         ],
                        'generic_names' => ''
                      }

    };

=head2 publication_search

    Usage: $sef->publication_search('AIDS');
    'AIDS' is just an example.. PharmGKB has a lot of publications
    about AIDS and it takes a long time for the SOAP to respond.

    This method is used to search for for publications.
    It returns a referenced hash like this :
    $var = {
          'PA133822615' => {
                           'authors' => [
                                          'Leabman Maya K',
                                          'Giacomini Kathleen M'
                                        ],
                           'page' => '581-4',
                           'volume' => '13',
                           'month' => '9',
                           'grant_id' => '',
                           'cross_reference' => [
                                                  {
                                                    'PubMed ID' => '12972957'
                                                  }
                                                ],
                           'title' => 'Estimating the contribution of genes and environment to variation in renal
				       drug clearance', 'abstract' => 'Renal excretion is the major pathway for
                                       elimination of many clinically used drugs and xenobiotics.
                                       We estimated the genetic component (rGC) contributing to variation in renal
                                       clearance for six compounds (amoxicillin, ampicillin, metformin, terodiline,
                                       digoxin and iohexol) using Repeated Drug Application methodology. Data were 
                                       obtained from published literature. The rGC values of renal clearance of 
                                       metformin, amoxicillin, and ampicillin, which undergo transporter-mediated 
                                       secretion, ranged from 0.64-0.94. This finding suggests that variation in the
                                       renal clearance of these drugs has a strong genetic component. Additionally,
                                       the rGC values of renal clearance of metformin, amoxicillin, and ampicillin 
                                       were similar to previously reported rGC values for metabolism. By contrast, 
                                       the rGC values of renal clearance for iohexol, digoxin, and terodiline were 
                                       low (0.12-0.37). Renal clearance of these compounds occurs mainly through 
                                       passive processes (e.g. glomerular filtration and passive secretion/reabsorption).
                                       The low rGC values of iohexol, digoxin and terodiline suggest that environmental
                                       factors may contribute to variation in their renal clearance.',
                           'grants_id' => [
                                            'GM61390'
                                          ],
                           'year' => '2003',
                           'journal' => 'Pharmacogenetics'
                         }
    };

=head1 TODO

    Return information instead of a bunch of PharmGKB IDs and try to make
    the SOAP respond faster. More features like phenotype/genotype data download.

=head1 AUTHOR

Arun Venkataraman, C<< <arvktr@gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-search-pharmgkb at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Search-PharmGKB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Search::PharmGKB

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Search-PharmGKB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Search-PharmGKB>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Search-PharmGKB>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Search-PharmGKB>

=back

You can contact the author for any issues or suggestions you come accross using this module.

=head1 ACKNOWLEDGEMENTS

This module is based on the perl client written by Andrew MacBride (andrew@helix.stanford.edu) for PharmGKB's web services.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Arun Venkataraman C<arvktr@gmail.com>, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut


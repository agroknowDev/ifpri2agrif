package gr.agroknow.metadata.transformer.dc2agrif;

import gr.agroknow.metadata.agrif.Agrif;
import gr.agroknow.metadata.agrif.Citation;
import gr.agroknow.metadata.agrif.ControlledBlock;
import gr.agroknow.metadata.agrif.Creator;
import gr.agroknow.metadata.agrif.Expression;
import gr.agroknow.metadata.agrif.Item;
import gr.agroknow.metadata.agrif.LanguageBlock;
import gr.agroknow.metadata.agrif.Manifestation;
import gr.agroknow.metadata.agrif.Relation;
import gr.agroknow.metadata.agrif.Rights;
import gr.agroknow.metadata.agrif.Publisher;

import gr.agroknow.metadata.transformer.ParamManager;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.ArrayList;

import net.zettadata.generator.tools.Toolbox;
import net.zettadata.generator.tools.ToolboxException;

%%
%class DC2AGRIF
%standalone
%unicode

%{
	// AGRIF
	private List<Agrif> agrifs ;
	private Agrif agrif ;
	private Citation citation ;
	private ControlledBlock cblock ;
	private Creator creator ;
	private Expression expression ;
	private Item item ;
	private LanguageBlock lblock ;
	private Manifestation manifestation ;
	private Relation relation ;
	private Rights rights ;
	private Publisher publisher ;
	
	// TMP
	private boolean notitle ;
	private StringBuilder tmp ;
	private String language ;
	private String date = null ;
	private List<Publisher> publishers = new ArrayList<Publisher>() ;
	
	// EXERNAL
	private String providerId ;
	private String manifestationType = "landingPage" ;
	
	public void setManifestationType( String manifestationType )
	{
		this.manifestationType = manifestationType ;
	}
	
	public void setProviderId( String providerId )
	{
		this.providerId = providerId ;
	}
	
	public List<Agrif> getAgrifs()
	{
		return agrifs ;
	}
	
	private void init()
	{
		agrif = new Agrif() ;
		agrif.setSet( providerId ) ;
		citation  = new Citation() ;
		cblock = new ControlledBlock() ;
		expression = new Expression() ;
		lblock = new LanguageBlock() ;
		relation = new Relation() ;
		publisher = new Publisher() ;
		notitle = true ;
	}
		
	private String utcNow() 
	{
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd" );
		return sdf.format(cal.getTime());
	}
	
	private String extract( String element )
	{	
		return element.substring(element.indexOf(">") + 1 , element.indexOf("</") );
	}
	
%}

%state AGRIF
%state TITLE
%state CREATOR
%state ISSUED
%state PUBLISHER
%state DESCRIPTION
%state LANGUAGE
%state ABSTRACT
%state IDENTIFIER
%state SUBJECT
%state RIGHTS
%state TYPE
%state RECORDNUMBER
%state RECORDSETIDENTIFIER
%state RECORDTRANSPORTIDENTIFIER
%state RECORDCONTENTSOURCE

%%

<YYINITIAL>
{	
	
	"<oclcdc:record"
	{
		agrifs = new ArrayList<Agrif>() ;
		init() ;
		yybegin( AGRIF ) ;
	}
}

<AGRIF>
{
	"</oclcdc:record>"
	{
		if ( manifestation != null )
		{
			if ( item != null )
			{
				manifestation.setItem( item ) ;
			}
			expression.setManifestation( manifestation ) ;
		}
		expression.setPublisher( publisher ) ;
		agrif.setExpression( expression ) ;
		agrif.setLanguageBlocks( lblock ) ;
		agrif.setControlled( cblock ) ;
		agrifs.add( agrif ) ;
		yybegin( YYINITIAL ) ;
	}
	
	"<dc:title>"
	{
		tmp = new StringBuilder() ;
		yybegin( TITLE ) ;
	}

	"<dc:creator>"
	{
		tmp = new StringBuilder() ;
		yybegin( CREATOR ) ;
	}
	
	"<dcterms:issued>"
	{
		tmp = new StringBuilder() ;
		yybegin( ISSUED ) ;
	}
	
	"<dc:publisher>"
	{
		tmp = new StringBuilder() ;
		yybegin( PUBLISHER ) ;
	}
	
	"<dc:description>"
	{
		tmp = new StringBuilder() ;
		yybegin( DESCRIPTION ) ;
	}

	"<dc:language>"
	{
		tmp = new StringBuilder() ;
		yybegin( LANGUAGE ) ;
	}
	
	"<dcterms:abstract>"
	{
		tmp = new StringBuilder() ;
		yybegin( ABSTRACT ) ;
	}	
	
	"<dc:identifier>"
	{
		tmp = new StringBuilder() ;
		yybegin( IDENTIFIER ) ;
	}
	
	"<dc:subject>"
	{
		tmp = new StringBuilder() ;
		yybegin( SUBJECT ) ;
	}
	
	"<dc:rights>"
	{
		tmp = new StringBuilder() ;
		yybegin( RIGHTS ) ;
	}
	
	"<dc:type>"
	{
		tmp = new StringBuilder() ;
		yybegin( TYPE ) ;
	}
	
	"<oclcterms:recordIdentifier xsi:type=\"oclcterms:oclcrecordnumber\">"
	{
		tmp = new StringBuilder() ;
		yybegin( RECORDNUMBER ) ;
	}
  
  	"<oclcterms:recordSetIdentifier>"
  	{
		tmp = new StringBuilder() ;
		yybegin( RECORDSETIDENTIFIER ) ;
	}
  
  	"<oclcterms:recordTransportIdentifier xsi:type=\"oclcterms:oairecordnumber\">"
	{
		tmp = new StringBuilder() ;
		yybegin( RECORDTRANSPORTIDENTIFIER ) ;
	}
	
	"<oclcterms:recordContentSource>"
	{
		tmp = new StringBuilder() ;
		yybegin( RECORDCONTENTSOURCE ) ;
	}
	
}

<RECORDCONTENTSOURCE>
{
	"</oclcterms:recordContentSource>"
	{
		yybegin( AGRIF ) ;
		// to complete
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<RECORDTRANSPORTIDENTIFIER>
{
	"</oclcterms:recordTransportIdentifier>"
	{
		yybegin( AGRIF ) ;
		// to complete
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<RECORDSETIDENTIFIER>
{
	"</oclcterms:recordSetIdentifier>"
	{
		yybegin( AGRIF ) ;
		// to complete
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<RECORDNUMBER>
{
	"</oclcterms:recordIdentifier>"
	{
		yybegin( AGRIF ) ;
		// to complete
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<TYPE>
{
	"</dc:type>"
	{
		yybegin( AGRIF ) ;
		if ( manifestation == null )
		{
			manifestation = new Manifestation() ;
		}
		manifestation.setFormat( tmp.toString() ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<RIGHTS>
{
	"</dc:rights>"
	{
		yybegin( AGRIF ) ;
		rights = new Rights() ;
		String tmptext = tmp.toString() ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		rights.setRightsStatement( language, tmptext ) ;
		agrif.setRights( rights ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<SUBJECT>
{
	"</dc:subject>"
	{
		yybegin( AGRIF ) ;
		String tmptext = tmp.toString() ;
		if ( ( tmptext.equals( tmptext.toUpperCase() ) ) && ( tmptext.length() > 8 ) )
		{
			for ( String coverage: tmptext.split( ";" ) )
			{
				cblock.setSpatialCoverage( "unknown", coverage.trim() ) ;
			}
		}
		else
		{
			language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
			for ( String keyword: tmptext.split( ";" ) )
			{
				if ( keyword.trim().length() > 3 )
				{
					lblock.setKeyword( language, keyword.trim().toLowerCase() ) ;
				}
			}
		}
		
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<IDENTIFIER>
{
	"</dc:identifier>"
	{
		yybegin( AGRIF ) ;
		String tmpIdentifier = tmp.toString() ;
		if ( tmpIdentifier.startsWith( "http://" ) )
		{
			item = new Item() ;
			item.setDigitalItem( tmpIdentifier ) ;
		}
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<ABSTRACT>
{
	"</dcterms:abstract>"
	{
		yybegin( AGRIF ) ;
		String tmptext = tmp.toString() ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		lblock.setAbstract( language, tmptext ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.
	{
		tmp.append( yytext() ) ; 
	}
	
	\n
	{
		tmp.append( " " ) ;
	}
}

<LANGUAGE>
{
	"</dc:language>"
	{
		yybegin( AGRIF ) ;
		String isolanguage = "en" ;
		try
		{
			isolanguage = Toolbox.getInstance().language2iso( tmp.toString().trim() ) ;
		}
		catch ( ToolboxException tbe ){} 
		expression.setLanguage( isolanguage ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<DESCRIPTION>
{
	"</dc:description>"
	{
		String tmptext = tmp.toString() ;
		yybegin( AGRIF ) ;
		if ( "Non-PR".equals( tmptext ) )
		{
			cblock.setReviewStatus( "unknown", "nonRefereed" ) ;
		}
		else if ( "Washington, D.C.".equals( tmptext ) )
		{
			publisher.setLocation( tmptext ) ;	
		}
		else if ( "Abuja, Nigeria".equals( tmptext ) )
		{
			publisher.setLocation( tmptext ) ;	
		}
		else if ( "Buenos Aires, Argentina".equals( tmptext ) )
		{
			publisher.setLocation( tmptext ) ;	
		}
		else if ( tmptext.contains( "pages" ) )
		{
			if (manifestation == null )
			{
				manifestation = new Manifestation() ;
			}
			manifestation.setSize( tmptext ) ; 
		} 
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.
	{
		tmp.append( yytext() ) ; 
	}
	
	\n
	{
		tmp.append( " " ) ;
	}
}

<PUBLISHER>
{
	"</dc:publisher>"
	{
		yybegin( AGRIF ) ;
		publisher.setName( tmp.toString() ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<ISSUED>
{
	"</dcterms:issued>"
	{
		yybegin( AGRIF ) ;
		publisher.setDate( tmp.toString() ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<CREATOR>
{
	"</dc:creator>"
	{
		String tmptext = tmp.toString() ;
		yybegin( AGRIF ) ;
		for (String name: tmptext.split(";") )
		{
			creator = new Creator( "person", name.trim() ) ;
			agrif.setCreator( creator ) ;
		}
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

<TITLE>
{
	"</dc:title>"
	{
		String tmptext = tmp.toString() ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		if (notitle)
		{
			lblock.setTitle( language, tmptext ) ;
			notitle = false ;	
		}
		else if ( tmptext.contains( "Paper" ) )
		{
			lblock.setNotes( language, tmptext ) ;
		}
		yybegin( AGRIF ) ;
		
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}
}

/* error fallback */
.|\n 
{
	//throw new Error("Illegal character <"+ yytext()+">") ;
}
